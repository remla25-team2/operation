# Confidence-Threshold Highlighting Experiment

This document details an A/B testing experiment designed to evaluate the impact of presenting users with confidence warnings for low-confidence predictions. We compare two versions of our application: `v1` (the control group, without warnings) and `v2` (the experimental group, which displays warnings for predictions with confidence below 0.7).

<!-- Please include a screenshot of your Grafana "A/B Testing Experiment Dashboard" here once the experiment is run. -->
<!-- Example: ![Experiment Dashboard Screenshot](/path/to/your/actual/screenshot.png) -->

## Table of Contents
1. [Hypothesis](#hypothesis)
2. [Metrics to measure the results of the experiment](#metrics-to-measure-the-results-of-the-experiment)
3. [Decision Process](#decision-process)
    * [Data Available (from Grafana)](#data-available-from-grafana)
    * [Concrete Decision Margins](#concrete-decision-margins)
4. [Results](#results)
    * [Experiment Configuration](#experiment-configuration)
    * [Implementation Details](#implementation-details)

---

## Hypothesis:

**Primary Hypothesis**: Presenting users with confidence warnings for low-confidence predictions (version `v2`) will lead to a **decrease in the rate of incorrect user feedback** and an **increase in user correction rate** compared to not showing warnings (version `v1`). This is expected to improve user understanding of model limitations and potentially lead to better model performance over time due to more accurate feedback data.

**Null Hypothesis**: Presenting confidence warnings will have no significant impact on the rate of incorrect user feedback or user correction rates.

## Metrics to measure the results of the experiment:
The following metrics are collected via Prometheus and visualized in Grafana to rigorously evaluate the experiment's outcome. Each metric is tailored to provide specific insights into the user experience and model behavior under both experimental conditions.

*   **Incorrect Prediction Rate by Version**:
    *   `rate(prediction_feedback_total{user_feedback="incorrect", version="v1"}[5m])`
    *   `rate(prediction_feedback_total{user_feedback="incorrect", version="v2"}[5m])`
    *   *Purpose*: This metric directly assesses if the confidence highlighting reduces instances where users explicitly mark a prediction as incorrect. A lower rate for `v2` would support the primary hypothesis.

*   **User Correction Rate by Version**:
    *   `rate(user_corrections_total{version="v1"}[5m])`
    *   `rate(user_corrections_total{version="v2"}[5m])`
    *   *Purpose*: Measures if users are more proactive in correcting predictions when confidence warnings are displayed. An increased rate for `v2` is a key indicator of improved user engagement with the prediction feedback mechanism.

*   **Low Confidence Prediction Rate by Version**:
    *   `rate(prediction_confidence_distribution_bucket{le="0.7", version="v1"}[5m])`
    *   `rate(prediction_confidence_distribution_bucket{le="0.7", version="v2"}[5m])`
    *   *Purpose*: Monitors the frequency of predictions falling below the 0.7 confidence threshold for each version. This confirms that the `v2` feature is indeed being triggered and allows us to see the volume of predictions that would typically trigger the warning.

*   **Overall Feedback Rate by Version**:
    *   `sum(rate(prediction_feedback_total{version="v1"}[5m]))`
    *   `sum(rate(prediction_feedback_total{version="v2"}[5m]))`
    *   *Purpose*: Ensures that the overall user engagement with the feedback system remains stable or improves across both versions, indicating the new feature doesn't deter users from providing feedback.
*   **Traffic Distribution by Version**:
    *   `sum(rate(http_requests_total[5m])) by (version)`
    *   *Purpose*: Essential for verifying that Istio's traffic routing (70/30 split) is functioning as intended, providing a reliable basis for comparing `v1` and `v2`.

*   **Response Latency Comparison**:
    *   `histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{exported_endpoint="/sentiment", version="v1"}[5m])) by (le))`
    *   `histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{exported_endpoint="/sentiment", version="v2"}[5m])) by (le))`
    *   *Purpose*: Monitors the 95th percentile of request durations. This metric is crucial for ensuring that the new feature in `v2` does not introduce any significant performance overhead or degradation in user experience.

*   **Incorrect Prediction Percentage by Version**:
    *   `sum(rate(prediction_feedback_total{user_feedback="incorrect", version="v1"}[5m])) / sum(rate(prediction_feedback_total{version="v1"}[5m]))`
    *   `sum(rate(prediction_feedback_total{user_feedback="incorrect", version="v2"}[5m])) / sum(rate(prediction_feedback_total{version="v2"}[5m]))`
    *   *Purpose*: Provides a normalized view of incorrect predictions, allowing for a direct percentage-based comparison between `v1` and `v2`, independent of overall traffic volume.

*   **User Corrections Breakdown by Version**:
    *   `sum(rate(user_corrections_total{version="v1"}[5m])) by (original_prediction, corrected_prediction)`
    *   `sum(rate(user_corrections_total{version="v2"}[5m])) by (original_prediction, corrected_prediction)`
    *   *Purpose*: Offers granular insight into *which* predictions are being corrected by users, which can help in identifying specific areas where the model struggles and where the confidence warnings are most effective.

*   **Flagged Predictions by Version**:
    *   `sum(rate(flagged_predictions_total{version="v1"}[5m])) by (reason)`
    *   `sum(rate(flagged_predictions_total{version="v2"}[5m])) by (reason)`
    *   *Purpose*: If the application introduces new flagging reasons related to confidence, this metric helps track their frequency and distribution across versions.

*   **Error Rate Comparison**:
    *   `rate(http_requests_total{status=~"5..", exported_endpoint="/sentiment", version="v1"}[5m])`
    *   `rate(http_requests_total{status=~"5..", exported_endpoint="/sentiment", version="v2"}[5m])`
    *   *Purpose*: A critical operational metric to ensure that the experimental version `v2` does not introduce an unacceptable increase in server-side errors, which would immediately indicate a problem.

*   **Model Service Errors/Warnings by Version**:
    *   `sum(rate(model_service_errors_total{version="v1"}[5m])) by (error_type)`
    *   `sum(rate(model_service_errors_total{version="v2"}[5m])) by (error_type)`
    *   `sum(rate(model_service_warnings_total{version="v1"}[5m])) by (warning_type)`
    *   `sum(rate(model_service_warnings_total{version="v2"}[5m])) by (warning_type)`
    *   *Purpose*: These metrics provide deep insight into the health and stability of the model service for each version, allowing us to pinpoint any issues directly attributable to the model itself or its integration.

## Decision Process:
The experiment aims to validate the hypothesis that confidence highlighting improves user interactions and prediction quality. The decision to promote `v2` (with confidence highlighting) or revert to `v1` (baseline) will be made based on a 5-minute observation period, utilizing the real-time Prometheus metrics visualized in the dedicated Grafana dashboard.

### Data available (from Grafana)

The experiment leverages the comprehensive monitoring infrastructure already in place, with custom Grafana dashboards (specifically the "A/B Testing Experiment Dashboard" imported via `grafana-dashboard-configmap.yaml`) providing real-time insights into the following key data points:

1.  **Prediction Confidence Distribution** - Available via [`prediction_confidence_distribution_bucket`](kubernetes/charts/my-app/dashboards/experiment-dashboard.json) metric. This visualizes how often low-confidence predictions occur for each version, ensuring the "warning" feature is active in `v2`.
2.  **User Feedback Tracking** - Monitored through [`prediction_feedback_total`](kubernetes/charts/my-app/templates/servicemonitor.yaml). This clearly shows the rates of `incorrect` feedback for both versions, enabling a direct comparison for our primary success criterion.
3.  **Correction Patterns** - Tracked via [`user_corrections_total`](kubernetes/charts/my-app/dashboards/experiment-dashboard.json). This graphs the frequency of user corrections, allowing us to see if `v2` prompts more user corrections.
4.  **Traffic Distribution** - A/B testing infrastructure from [`istio-gateway.yaml`](kubernetes/charts/my-app/templates/istio-gateway.yaml). The dashboard includes a pie chart confirming the actual traffic split (70% to `v1`, 30% to `v2`) as configured by the Istio `VirtualService`.
5.  **Real-time Dashboards** - Custom Grafana dashboards automatically imported via [`grafana-dashboard-configmap.yaml`](kubernetes/charts/my-app/templates/grafana-dashboard-configmap.yaml). All specified metrics are presented in time-series graphs and stat panels, enabling immediate assessment of the experiment's impact.

### Concrete decision margins

**Success Criteria** (measured over 5-minute observation window):

*   **Primary Objective**: The `Incorrect Prediction Rate by Version` for `v2` must be **observably lower** than `v1`. The "Incorrect Prediction Percentage by Version" stat panel should clearly show a reduction for `v2`.
*   **Secondary Objective**: The `User Correction Rate by Version` for `v2` must be **observably higher** than `v1`. The "User Correction Rate by Version" time-series panel will illustrate this trend.
*   **Stability Check**: The `Error Rate Comparison` for `v2` must remain **comparable or lower** than `v1`. A significant spike in the `v2` error rate would indicate a critical issue.
*   **Engagement Check**: The `Overall Feedback Rate` for `v2` should remain **stable or slightly increase** compared to `v1`, indicating the feature does not negatively impact user engagement.
*   **Feature Verification**: The `Low Confidence Prediction Rate by Version` for `v2` should show **active and expected values** (i.e., non-zero rate when predictions fall below 0.7 confidence), confirming the feature is functioning as designed.

If these criteria are met, particularly the primary and secondary objectives without significant degradation in stability or engagement, `v2` will be considered successful and potentially rolled out to 100% of the traffic.

**Failure Criteria**:

*   `Incorrect Prediction Rate by Version` for `v2` is **equal to or higher** than `v1`.
*   `User Correction Rate by Version` for `v2` is **equal to or lower** than `v1`.
*   A significant **increase in `Error Rate Comparison`** for `v2` (e.g., above 1% or notably higher than `v1`).
*   A significant **decrease in `Overall Feedback Rate`** for `v2` (e.g., more than 10% drop compared to `v1`).

If any of these failure criteria are met, `v2` will be deemed unsuccessful, and traffic will be immediately reverted to `v1` (by setting `v2` weight to 0% in `values.yaml` and performing a Helm upgrade).

**Traffic Split**:

*   `v1` (Control): 70% - No confidence warnings
*   `v2` (Experiment): 30% - Show warnings when confidence < 0.7

## Results

**Screenshot of Experiment Dashboard:**
<!-- Insert your actual screenshot here -->
![Experiment Dashboard Screenshot](/path/to/your/actual/screenshot.png)

### Experiment Configuration
-   **Duration**: 5 minutes (for decision-making snapshot)
-   **Traffic Split**: 70/30 (control/experiment)
-   **Monitoring**: Real-time via [Prometheus alerts](kubernetes/charts/my-app/templates/custom_prometheus_rules.yaml) and the dedicated Grafana dashboard.

### Implementation Details
-   Experiment managed via [Istio traffic routing](kubernetes/charts/my-app/templates/istio-gateway.yaml), using `VirtualService` and `DestinationRule` for weighted routing and consistent hashing.
-   Metrics collected through [ServiceMonitor](kubernetes/charts/my-app/templates/servicemonitor.yaml) which scrapes `/metrics` endpoint on the `app` service.
-   Dashboards are available at `http://localhost:3000` (Grafana) after port-forwarding. Log in with username: `admin` and password: (the one you set when running `create_secrets.sh`).
