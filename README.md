# Saliency-Detection-FDC

Fast Visual Saliency Based on Multi-scale Difference of Gaussians Fusion in Frequency Domain.  
For more information, please contact author by: williamli_pro@163.com

The preprint has been submitted to:
https://www.researchgate.net/publication/333809502_Fast_Saliency_Detection_Algorithm_Based_on_Multi-scale_Difference_of_Gaussians_Fusion_in_Frequency_Domain

# Abstract
To reduce the computation required in determining the proper scale of salient object, a fast visual saliency based on multi-scale difference of Gaussians fusion in frequency domain (MDF) is proposed. Firstly, based on the phenomenon that the foreground energy is highlighted and densely distributes on certain band of spectrum, the scale coefficients of foreground in an image can be literately approximated on the amplitude spectrum. Next, relying on the linear integration property of Fourier transform, the feature spectrum is obtained through the weighted infinite integral of DoG feature maps with respect to the scale of object. Then, the saliency of each channel is obtained from feature spectrum by the inverse Fourier transform and scale filtering. Finally, through the channel integration, the MDF saliency map is obtained. Experiments on Li-Jian dataset demonstrate that combined with most appropriate color space and scale filter, MDF achieves obvious acceleration while getting desired accuracy, which achieves the best accuracy efficiency trade-off.

# Results
![Procedures](https://raw.githubusercontent.com/WilliamLiPro/Saliency-Detection-FDC/master/Part-of-experiment-result/procedures.png)

![filter example](https://raw.githubusercontent.com/WilliamLiPro/Saliency-Detection-FDC/master/Part-of-experiment-result/filter-example.png)

![saliency maps comparison](https://raw.githubusercontent.com/WilliamLiPro/Saliency-Detection-FDC/master/Part-of-experiment-result/saliency_maps.png)

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

