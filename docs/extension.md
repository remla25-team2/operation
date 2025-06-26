<!--
Extension Proposal Critically reflect on the current state of your project and identify one release-engineering-
related shortcoming of the project practices that you find the most critical, annoying, or error prone (related to an
assignment, e.g., the training or release pipelines, contribution process, deployment, or experimentation).
Document the identified shortcoming and describe its effect, a convincing argumentation is crucial. Describe
and visualize a project refactoring or an extension that would improve the situation. Link to information sources
that provide additional information, inspiration for your solution, or concrete examples for its realization. We expect
that you only cite respectable sources (e.g., research papers, quality blogs like Medium, tool websites, or popular
StackOverflow discussions). It is critical that you describe how you could test whether the changed design would
solve the identified shortcoming, i.e., how an experiment could be designed to measure the resulting effects
-->

<!-- 
Extension Proposal (The documentation refers to the docs/extension.md file)
Insufficient
The extension is unrelated to release engineering and focuses on an implementation aspect.

Poor
The extension is trivial, irrelevant for the project, or refers to an unimplemented assessment criterion.

Sufficient
- The documentation describes one release-engineering-related shortcoming of the project practices.
- A proposed extension addresses the shortcoming and is connected to one of the assignments. 
    For example, the training or release pipelines, contribution process, deployment, or experimentation.
- The extension is genuine and has not already been mentioned in any of the assignment rubrics.
- The documentation cites external sources that inspired the envisioned extension.

Good
- The shortcoming is critically reflected on and its negative effects get elaborated in detail.
- The presented extension improves the described shortcoming.
- The documentation explains how an improvement could be measured objectively in an experiment.

Excellent
- The presented extension is general in nature and applicable beyond the concrete project.
- The presented extension clearly overcomes the described shortcoming
-->

# Extension Proposal: Experiment Dashboard for Model Training with MLFlow

## Identified Shortcoming

One significant shortcoming in the project's release engineering practices is the absence of an experiment tracking and visualization system. While DVC is used to manage data and model artifacts, there is no centralized way to log and compare experiment metadata like hyperparameters, evaluation metrics, or model versions in a human-readable format. This makes it difficult to reproduce results, collaborate effectively, or understand which model should be promoted to production. As the project scales, this lack of visibility and traceability increases the risk of duplicated effort, inconsistent deployments, and lost experimentation insights. Introducing an experiment dashboard would enable the team to organize and evaluate their models systematically, ultimately improving reliability, collaboration, and iteration speed.


This has multiple negative effects:
- **Reproducibility:** Without clear logging, it is hard to trace which parameters / architecture led to which model. Cannot reliably rerun or compare past experiments
- **Collaboration bottlenecks:** Team members cannot see each other's experiment results. 
- **Wasted Compute Time:** Same experiments may be run repeatedly without realizing
- **Lack of Visiblity during CI/CD:** No centralized view of experiment status, accuracy, training time, etc.

### Proposed Extension
A platform for managing the machine learning lifecycle would solve this problem. MLflow is an open-source platform that helps manage the end-to-end machine learning lifecycle. It provides tools for tracking experiments (logging parameters, metrics, and artifacts), packaging models for reproducible runs, and deploying them to production. MLflow includes a user-friendly UI for visualizing and comparing runs, as well as a model registry to manage different model versions. It supports integration with popular ML libraries and can be run locally or hosted in the cloud, making it a flexible solution for experiment tracking and model management.


### How to Measure Improvement

The improvement offered by integrating MLflow is the simplification and streamlining of large collaborative ML Projects. It mainly offers time savings and ease to developers in ML Model training and deployment. Therefore it's impact can be best measured through the difference in time taken for a various tasks that developers undertake with and without MLFlow. 


### 📊 Measuring MLflow's Impact: Before vs After Integration

| **Aspect**                    | **Metric**                                         | **How to Measure**                                                                 |
|------------------------------|---------------------------------------------------|------------------------------------------------------------------------------------|
| Reproducibility              | Time to reproduce a previous result               | Time taken by a team member to rerun and match past experiment results            |
| Experiment traceability      | Number of runs with missing metadata              | Count of training runs without logged parameters/metrics before vs. after         |
| Model selection confidence   | Time/effort to decide on best-performing model    | Survey contributors or time decision-making using logs/UI                         |
| Collaboration efficiency     | Number of duplicated experiments                  | Count repeated runs with identical parameters                                     |
| Pipeline auditability        | Ratio of runs with complete artifact logs         | Percentage of experiments with fully logged params, metrics, and artifacts        |


### General Applicability

MLflow is general-purpose and widely applicable across many machine learning workflows, frameworks, and industries.

It is framework-agnostic—meaning it works with scikit-learn, TensorFlow, PyTorch, HuggingFace and others. It supports any language that can make HTTP requests (official APIs exist for Python, R, Java, and REST). MLflow’s modular architecture (Tracking, Projects, Models, Registry) allows teams to adopt only the components they need.


