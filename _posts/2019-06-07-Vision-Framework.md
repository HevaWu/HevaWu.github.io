---
layout: post
title: Vision Framework
date: 2019-06-07 14:35:00
cover: nil
comments: true
disqus_category_id: VisionFramework
categories: [iOS, Image Processing, Vision]
tags: [iOS, Image Processing, Vision]
---

Since WWDC 2018, Apple introduces the `Vision` Framework.
And I'd like to take some nots on it.

# Saliency

Saliency generated people's attension & objectness.
Highlight when people watch the image.

Attention Based
- Human Aspected
- Trained on eye movements

Objectness Based
- Foreground Objects
- Trained on object segmentation

Here is an example image:
The first picture is the original picture
The second is attention based picture
The third is objectness based picture
<img src="/images/2019-06-07-Vision-Framework/attention_objectness.png" width="100%">

## Determined by
- Contrast
- Faces
- Subjects
- Horizons
- Light

## Heatmap
Use `VNGenerateAttensionBasedSaliencyImageRequest` & `VNGenerateObjectnessBasedSaliencyImageRequest`
to generate the image with the highlight picture.
The highlight part is covered by a heatmap, which point out the Saliency part.
<img src="/images/2019-06-07-Vision-Framework/saliency_example_code.png" width="100%">

## Bounding Box
For attension of the saliency, we will have a bounding box, which
could draw out the correct image area.

Here is an example code about how to adding th bounding box and showing it.
<img src="/images/2019-06-07-Vision-Framework/saliency_boundbox.png" width="100%">

## Graphical Uses
Add type of filter or photo transition.
<img src="/images/2019-06-07-Vision-Framework/saliency_graphic_uses.png" width="100%">

# Image Classification
1. Use saliency to detect the object & return the bounding box-es
2. For each bounding box, use image classification to find out which object it is.

## Taxonomy
Hierarchical structure, containing around 100 classes.
Grouping based on shared semantic meanings.
Define relationships between classes of increasing specificity.

### Taxonomy Construction
Include classes that are visually identifiable

*Avoid*
- Abstract /controversial concepts
- Proper nouns, adjectives, and basic shapes
- Occupations

Here is the result of classify image
<img src="/images/2019-06-07-Vision-Framework/image_classification.png" width="100%">

*Terms*
Confidence > Threshold => Predicted image
- Precision and Recall

Add `hasMinimumPrecision` & `Recall` params to help filtering the high precision images.
<img src="/images/2019-06-07-Vision-Framework/image_classify_recall.png" width="100%">

    - PR Curve
<img src="/images/2019-06-07-Vision-Framework/image_pr_curve.png" width="100%">

    - Use Recall & Precision to controll get the high precision
<img src="/images/2019-06-07-Vision-Framework/filter_pr_curve.png" width="100%">

## Summary
Returned observation contains labels and an associated confidence.
Choice of threshold is application specific.
Can be determined by desired precision and recall.

# Image Similarity
<img src="/images/2019-06-07-Vision-Framework/image_similarity.png" width="100%">

Descriptor should describes image content, not just appearance.
Classification network creates representations of images.
FeaturePrint - vector image descriptor similar to a word vector.

## Demo
<img src="/images/2019-06-07-Vision-Framework/demo_image_similarity.png" width="100%">

# Face Technology
## Face Landmarks
<img src="/images/2019-06-07-Vision-Framework/face_landmarks.png" width="100%">
<img src="/images/2019-06-07-Vision-Framework/face_landmarks_demo.png" width="100%">

`VNDetectedObjectObservation` contain bounding Box -> `VNFaceObservation`(landmarks)
`VNFaceLandmarks` confidence -> `VNFaceLandmarks2D` (eyes...)

Revision Example -- default versus explicit
<img src="/images/2019-06-07-Vision-Framework/face_landmarks_revision.png" width="100%">
76points -> 2019 SDK

## Face Capture Quality
Face Capture Quality is a holistic measure that considers:
lighting, blur, occlusion, expression, pose, ...
<img src="/images/2019-06-07-Vision-Framework/face_capture_quality.png" width="100%">

Face capture quality should not be compared against a threshold.
Face capture quality is a `comparative` measure of the `same` subject.

# New Detector
- Human Detector
- Cat and Dog Detector
<img src="/images/2019-06-07-Vision-Framework/new_detectors.png" width="100%">

# Tracking Enhancements
Less expansion into the background
Better handling of occlusions
Machine Learning based
Runs on CPU, GPU, and A12 Bionic with low power consumption
<img src="/images/2019-06-07-Vision-Framework/tracking_vision.png" width="100%">
- `VNSequenceRequestHandler()`
- `inputObservation`
could add revision -> `request.revision = VNTrackObjectRequestRevision2`

# Vision and CoreML Integration Enhancements
Vision now works with CoreML models that have `single input` of `image type`
Vision converts `Inputs` image to CoreML required input size and color scheme
Vision wraps `Outputs` into appropriate Observation types
<img src="/images/2019-06-07-Vision-Framework/vision_coreML.png" width="100%">

Vision can now work with CoreML models that have `one or more` `Inputs`
- Including `multi-image` inputs
Vision will use `name-mapping` of `Output` names to Observations

<img src="/images/2019-06-07-Vision-Framework/vision_coreML_api.png" width="100%">

