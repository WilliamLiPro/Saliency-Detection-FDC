# Saliency-Detection-FDC

Fast Visual Saliency Based on Multi-scale Difference of Gaussians Fusion in Frequency Domain.  
For more information, please contact author by: williamli_pro@163.com

The preprint has been submitted to:
https://www.researchgate.net/publication/333809502_Fast_Saliency_Detection_Algorithm_Based_on_Multi-scale_Difference_of_Gaussians_Fusion_in_Frequency_Domain

# Abstract
Aiming at the problem in visual saliency detection with frequency domain analysis where the scale information of different frequency cannot be fully used at present, a fast saliency detection algorithm based on multi-scale Difference of Gaussians fusion in frequency domain is proposed. Based on the Difference of Gaussians feature, the Difference of Gaussians operator at all scales is integrated in the frequency domain by using the linear property of Fourier transform, so that a saliency map with comprehensive features of Difference of Gaussians in all scales is obtained. To improve the robustness of the algorithm, the cutoff frequency of the foreground feature is adaptively estimated based on the prior distribution of the high frequency and the low frequency in the spectrum. To improve the accuracy of saliency detection, the Lab color space and post-processing with Difference of Gaussians filter are applied to enhance the adaptability of the algorithm to foregrounds in various scales and to suppress the background noise. Experiments in dataset show that the proposed algorithm maintains high real-time performance (28.0ms) while ensuring high precision (AUC exceeds 0.9018). It effectively overcomes the difficulty of combining both accuracy and real-time performance for the saliency detection based on frequency domain analysis.

# Results
![Procedures](https://raw.githubusercontent.com/WilliamLiPro/Saliency-Detection-FDC/master/Part-of-experiment-result/procedures.png)

![filter example](https://raw.githubusercontent.com/WilliamLiPro/Saliency-Detection-FDC/master/Part-of-experiment-result/filter-example.png)

![saliency maps comparison](https://raw.githubusercontent.com/WilliamLiPro/Saliency-Detection-FDC/master/Part-of-experiment-result/saliency-maps.png)

![MAP](https://raw.githubusercontent.com/WilliamLiPro/Saliency-Detection-FDC/master/Part-of-experiment-result/MAP.jpg)

![AUC](https://raw.githubusercontent.com/WilliamLiPro/Saliency-Detection-FDC/master/Part-of-experiment-result/AUC.jpg)

![ACC](https://raw.githubusercontent.com/WilliamLiPro/Saliency-Detection-FDC/master/Part-of-experiment-result/ACC.jpg)

# References
> [1]	BORJI A, CHENG M M, HOU Q, et al. Salient Object Detection: A Survey[J]. Eprint Arxiv, 2014, 16(7):3118.

> [2]	GUO C, MA Q, ZHANG L. Spatio-temporal Saliency detection using phase spectrum of quaternion fourier transform[C]. Computer Vision and Pattern Recognition, 2008. CVPR 2008. IEEE Conference on. IEEE, 2008:1-8.

> [3]	ITTI L, KOCH C, NIEBUR E. A model of saliency-based visual attention for rapid scene analysis[M]. IEEE Computer Society, 1998.

> [4]	HOU X, ZHANG L. Saliency Detection: A Spectral Residual Approach[C]. Computer Vision and Pattern Recognition, 2007. CVPR 07. IEEE Conference on. IEEE, 2007:1-8.

> [5]	GUO C, MA Q, ZHANG L. Spatio-temporal Saliency detection using phase spectrum of quaternion fourier transform[C]. Computer Vision and Pattern Recognition, 2008. CVPR 2008. IEEE Conference on. IEEE, 2008:1-8.

> [6]	ACHANTA R, ESTRADA F, WILS P, et al. Salient Region Detection and Segmentation[C]. International Conference on Computer Vision Systems. Springer, Berlin, Heidelberg, 2008:66-75.

> [7]	ACHANTA R, HEMAMI S, ESTRADA F, et al. Frequency-tuned salient region detection[C]. Computer Vision and Pattern Recognition, 2009. CVPR 2009. IEEE Conference on. IEEE, 2009:1597-1604.

> [8]	LI J, LEVINE M D, AN X, et al. Visual Saliency Based on Scale-Space Analysis in the Frequency Domain[J]. IEEE Transactions on Pattern Analysis & Machine Intelligence, 2013, 35(4):996-1010.

> [9]	YU Y, WANG B, ZHANG L. Pulse discrete cosine transform for saliency-based visual attention[C]. IEEE, International Conference on Development and Learning. IEEE, 2009:1-6.

> [10]	BIAN P, ZHANG L. Visual saliency: a biologically plausible contourlet-like frequency domain approach[J]. Cogn Neurodyn, 2010, 4(3):189-198.

> [11]	HOU X, HAREL J, KOCH C. Image Signature: Highlighting Sparse Salient Regions[J]. IEEE Transactions on Pattern Analysis & Machine Intelligence, 2012, 34(1):194.

> [12]	SHI J, YAN Q, XU L, et al.. Hierarchical saliency detection on extended CSSD[J]. IEEE Transactions on Pattern Analysis & Machine Intelligence, 2014, 38(4): 717.

> [13]	HUANG KAN, ZHU CHUNBIAO, LI GE. Saliency Detection by Adaptive Channel Fusion[J]. IEEE Signal Processing Letters,2018,25(7): 1059-1063.

> [14]	MU NAN, XU XIN, ZHANG XIAOLONG. A spatial-frequency-temporal domain based saliency model for low contrast video sequences[J]. Journal of Visual Communication and Image Representation, 2019,58: 79-88.

> [15]	LIU SHANGWANG, HU JIANLAN. Visual saliency based on frequency domain analysis and spatial information[J]. Multimedia Tools and Applications,2016,75(23): 16699-16711.

