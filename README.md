# Saliency-Detection-MDF

Fast Visual Saliency Based on Multi-scale Difference of Gaussians Fusion in Frequency Domain.  
For more information, please contact author by: williamli_pro@163.com

The preprint has been submitted to:
https://www.researchgate.net/publication/333809502_Fast_Saliency_Detection_Algorithm_Based_on_Multi-scale_Difference_of_Gaussians_Fusion_in_Frequency_Domain

# Abstract
To reduce the computation required in determining the proper scale of salient object, a fast visual saliency based on multi-scale difference of Gaussians fusion in frequency domain (MDF) is proposed. Firstly, based on the phenomenon that the foreground energy is highlighted and densely distributes on certain band of spectrum, the scale coefficients of foreground in an image can be literately approximated on the amplitude spectrum. Next, relying on the linear integration property of Fourier transform, the feature spectrum is obtained through the weighted infinite integral of DoG feature maps with respect to the scale of object. Then, the saliency of each channel is obtained from feature spectrum by the inverse Fourier transform and scale filtering. Finally, through the channel integration, the MDF saliency map is obtained. Experiments on Li-Jian dataset demonstrate that combined with most appropriate color space and scale filter, MDF achieves obvious acceleration while getting desired accuracy, which achieves the best accuracy efficiency trade-off.

# System requirements
This is the Matlab code. 

# Demo
Please run test_run.m in Matlab environment.  

# Results
![Procedures](https://raw.githubusercontent.com/WilliamLiPro/Saliency-Detection-FDC/master/Part-of-experiment-result/procedure.png)

![filter example](https://raw.githubusercontent.com/WilliamLiPro/Saliency-Detection-FDC/master/Part-of-experiment-result/filter-example.png)

![saliency maps comparison](https://raw.githubusercontent.com/WilliamLiPro/Saliency-Detection-FDC/master/Part-of-experiment-result/saliency_maps.png)

# References
