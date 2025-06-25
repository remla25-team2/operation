# Confidence-Threshold Highlighting Experiment

![Experiment Dashboard](../kubernetes/charts/my-app/dashboards/experiment-dashboard.json)


## Hypothesis:

**Primary Hypothesis**: 


## Metrics to measure the results of the experiment:

# Incorrect Prediction Rate by Version
- rate(prediction_feedback_total{user_feedback="incorrect", version="v1"}[5m])
- rate(prediction_feedback_total{user_feedback="incorrect", version="v2"}[5m])

# User Correction Rate by Version
- rate(user_corrections_total{version="v1"}[5m])
- rate(user_corrections_total{version="v2"}[5m])

# Low Confidence Prediction Rate by Version (this can change)
- rate(prediction_confidence_distribution_bucket{le="0.7", version="v1"}[5m])
- rate(prediction_confidence_distribution_bucket{le="0.7", version="v2"}[5m])

# Overall Feedback Rate by Version
- sum(rate(prediction_feedback_total{version="v1"}[5m]))
- sum(rate(prediction_feedback_total{version="v2"}[5m]))
## Decision process:

### Data available (from Grafana)

The experiment leverages the comprehensive monitoring infrastructure already in place:

1. **Prediction Confidence Distribution** - Available via [`prediction_confidence_distribution_bucket`](kubernetes/charts/my-app/dashboards/experiment-dashboard.json) metric
2. **User Feedback Tracking** - Monitored through [`prediction_feedback_total`](kubernetes/charts/my-app/templates/servicemonitor.yaml) 
3. **Correction Patterns** - Tracked via [`user_corrections_total`](kubernetes/charts/my-app/dashboards/experiment-dashboard.json)
4. **Traffic Distribution** - A/B testing infrastructure from [`istio-gateway.yaml`](kubernetes/charts/my-app/templates/istio-gateway.yaml)
5. **Real-time Dashboards** - Custom Grafana dashboards automatically imported via [`grafana-dashboard-configmap.yaml`](kubernetes/charts/my-app/templates/grafana-dashboard-configmap.yaml)

### Concrete decision margins

**Success Criteria** (measured over 5m period):


**Failure Criteria**:

**Traffic Split**: 
- v1 (Control): 70% - No confidence warnings
- v2 (Experiment): 30% - Show warnings when confidence < 0.7

## Results



### Experiment Configuration
- **Duration**: 5 min
- **Traffic Split**: 70/30 (control/experiment)
- **Monitoring**: Real-time via [Prometheus alerts](kubernetes/charts/my-app/templates/custom_prometheus_rules.yaml)

### Implementation Details
- Experiment managed via [Istio traffic routing](kubernetes/charts/my-app/templates/istio-gateway.yaml)
- Metrics collected through [ServiceMonitor](kubernetes/charts/my-app/templates/servicemonitor.yaml)
- Dashboards available at `http://localhost:3000` (Grafana) after port-forwarding