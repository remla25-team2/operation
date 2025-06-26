# Continuous Experimentation: Sentiment Color-Coding A/B Test

## Overview

We are conducting a canary (A/B) experiment to evaluate the impact of color-coded sentiment feedback on user engagement. The goal is to determine whether displaying sentiment results in color (green for positive, red for negative) increases user feedback compared to a neutral, non-colored display.

---

## Experiment Design

### Baseline (v0.2.2, With Color)

- **Frontend:** Sentiment results are shown in green (positive) or red (negative).
- **Docker image:** `ghcr.io/remla25-team2/app:v0.2.2`
- **Branch:** `main` (or release branch)
- **User experience:** Immediate visual cue for sentiment.

### Experiment (v0.2.3, No Color)

- **Frontend:** Sentiment results are shown with no color (neutral styling).
- **Docker image:** `ghcr.io/remla25-team2/app:v0.2.3`
- **Branch:** `feature/no-color-experiment`
- **User experience:** No visual color cue for sentiment.

---

## Hypothesis

> **Displaying sentiment results in color will increase the rate of user feedback compared to a non-colored display.**

- **Null hypothesis:** There is no difference in user feedback rate between color and no-color versions.
- **Alternative hypothesis:** The color version increases user feedback rate.

---

## Metrics and Monitoring

### Primary Metric

- **User Feedback Rate:**  
  The ratio of sentiment predictions that receive any user feedback (`correct`, `incorrect`, or correction) to the total number of sentiment analysis requests.
  - **Prometheus Query Example:**  
    ```
    sum(rate(prediction_feedback_total{version="v1"}[5m])) / sum(rate(http_requests_total{exported_endpoint="/sentiment", version="v1"}[5m]))
    ```
    (Repeat for `version="v2"`.)

### Secondary Metric

- **User Correction Rate:**  
  The ratio of predictions that receive an explicit correction to the total number of sentiment requests.

### Health Metrics

- **Request Rate**
- **Latency**
- **Error Rate**

### Monitoring

- **Grafana Dashboard:**  
  The `A/B Testing Dashboard` visualizes feedback rates, correction rates, traffic split, and health metrics for both versions.
- **Prometheus:**  
  Scrapes metrics from both app versions, labeled by `version`.

---

## Traffic Management

- **Istio VirtualService:**  
  Splits traffic 70% to v0.2.2 (color) and 30% to v0.2.3 (no color) using sticky sessions (consistent hash on cookie).
- **Helm values.yaml:**
    ```yaml
    experiment:
      enabled: true
      versions:
        v1:
          weight: 70
          image:
            repository: ghcr.io/remla25-team2/app
            tag: v0.2.2
        v2:
          weight: 30
          image:
            repository: ghcr.io/remla25-team2/app
            tag: v0.2.3
    ```

---

## Implementation Steps

1. **Prepare branches and Docker images:**
    - `main` branch: color version (`v0.2.2`)
    - `feature/no-color-experiment` branch: no-color version (`v0.2.3`)
    - Build and push both images to registry.

2. **Update Helm chart:**
    - Set `experiment.enabled: true` and configure both versions/tags and weights.

3. **Deploy with Helm:**
    ```bash
    helm upgrade --install my-app ./kubernetes/charts/my-app
    ```

4. **Generate traffic:**
    - Use the app frontend as a user, provide feedback, and corrections.

5. **Monitor in Grafana:**
    - Access Grafana (`kubectl --namespace monitoring port-forward svc/prometheus-operator-grafana 3000:80`)
    - Open the `A/B Testing Dashboard` to compare feedback rates.

---

## Success Criteria

- **Success:**  
  If the color version (`v0.2.2`) shows a statistically significant increase (e.g., >10% relative improvement) in user feedback rate compared to the no-color version (`v0.2.3`), and no negative impact on health metrics, the experiment is considered successful.

- **Failure:**  
  If there is no significant difference, or the no-color version performs better, or health metrics degrade, the experiment is considered unsuccessful.

---

## Rollback Plan

- If the experiment causes errors or negative user impact, set `v1.weight: 100`, `v2.weight: 0` in `values.yaml` and redeploy to route all traffic to the baseline.

---

## Next Steps

- If successful, promote the color version to 100% of users.
- If not, analyze user behavior and consider alternative UI improvements.

---

## Dashboard Example

![Grafana A/B Dashboard Screenshot](images/grafana_ab_dashboard.png) <!-- Replace with your actual screenshot -->

---

**This experiment demonstrates continuous delivery and data-driven UI improvement using Kubernetes, Istio, Prometheus, and Grafana.**
