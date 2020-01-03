# Saliency-Detection-on-Multi-feature-
Saliency Detection based on multi-feature distribution and Machine Learning theory.  
For more information, please contact author by: williamli_pro@163.com

<<<<<<< HEAD
If you'd like to use this code, please cite: 
YANG Xiao-gang, LI Wei-peng, MA Ma-shuang. Saliency Detection with Multi-features in Probability Framework. Acta Electronica Sinica, 2019, 47(11): 2378-2385. 
DOI: 10.3969/j.issn.0372-2112.2019.11.020
=======
The preprint (written in Chinese) has been submitted to:
https://www.researchgate.net/publication/333810669_Saliency_Detection_with_Multi-features_in_Probability_Framework
>>>>>>> b4f53c5fb3080b29c2d8bf41cb03bae9db63bf74

## Abstract:
In order to improve the precision of visual saliency detection with multi-features, a multi-feature integration algorithm is proposed based on the joint probability distribution of saliency map and combined with priori knowledge. Firstly, the potential defects of single feature saliency detection are analyzed, and the joint probability distribution of saliency maps with multiple features is deduced. Secondly, the priori distribution of the saliency map is deduced based on the rarity, sparsity, compactness and center priori of the saliency map, and the condition distribution of the saliency map is simplified based on the assumption of normal distribution. Then the maximum a posteriori estimation is obtained from the joint probability distribution of the saliency map, and a supervised learning model of the distribution parameters is constructed based on the multi-threshold hypothesis. Experiments show that compared to the highest-precision saliency detection method on single feature, the mean average error of the multi-feature algorithm under the supervised and heuristic method is decreased by 6.98% and 6.81%, and the average F-measure is improved by 1.19% and 1.16%. And the multi-feature integration of single image takes only 11.8ms. The algorithm has high accuracy and real-time performance, and can be combined with the required features and different prior information according to the task. It meets the requirements of saliency detection with multi-features.

## results:
![Saliency detection comparison](https://raw.githubusercontent.com/WilliamLiPro/Saliency-Detection-on-Multi-feature-/master/result-to-show/comparison.jpg)

![Precision-Recall for heuristic Multi-feature fusion](https://github.com/WilliamLiPro/Saliency-Detection-on-Multi-feature-/raw/master/result-to-show/PR-hMF.png)

![Precision-Recall for supervised Multi-feature fusion](https://github.com/WilliamLiPro/Saliency-Detection-on-Multi-feature-/raw/master/result-to-show/PR-supMF.png)

## Referances:
> [1]	BORHI A, CHENG M M, HOU Q, et al. Salient Object Detection: A Survey[J]. Eprint Arxiv, 2014, 16(7): 3118-3137.  
> [2]	BORHI A, SIHITE D N, ITTI L. Salient Object Detection: A Benchmark[M]// Computer Vision – ECCV 2012. Springer: Berlin Heidelberg, 2012: 414-429.  
> [3]	GUO C, MA Q, ZHANG L. Spatio-temporal Saliency detection using phase spectrum of quaternion fourier transform[C]// Computer Vision and Pattern Recognition, 2008. IEEE Conference on. IEEE, 2008: 1-8.  
> [4]	HOU X, ZHANG L. Saliency Detection: A Spectral Residual Approach[C]// Computer Vision and Pattern Recognition, 2007. CVPR '07. IEEE Conference on. IEEE, 2007: 1-8.  
> [5]	ZHEN Y F, ZHANG X W, XIA T Y, et al. The Semantic Salient Region Detection Algorithm Based on the Fully Convolutional Networks[J]. Acta Electronica Sinica, 2017, 45(11): 2593-2601.  
> [6]	ACHANTA R, ESTRADA F, WILS P, et al. Salient Region Detection and Segmentation[C]// International Conference on Computer Vision Systems. Springer: Berlin, Heidelberg, 2008: 66-75.  
> [7]	Harel J, Koch C, Perona P. Graph-Based Visual Saliency[C]// International Conference on Neural Information Processing Systems. MIT Press, 2006: 545-552.  
> [8]	ITTI L, KOCH C, NIEBUR E. A model of saliency-based visual attention for rapid scene analysis[M]. IEEE Computer Society, 1998.  
> [9]	MA Y F, ZHANG H J. Contrast-based image attention analysis by using fuzzy growing[C]// Eleventh ACM International Conference on Multimedia. ACM, 2003: 374-381.  
> [10]	ACHANDA R, HEMAMI S, Estrada F, et al. Frequency-tuned salient region detection[C]// Computer Vision and Pattern Recognition, 2009. CVPR 2009. IEEE Conference on. IEEE, 2009: 1597-1604.  
> [11]	Yan Q , Xu L , Shi J, et al. Hierarchical Saliency Detection[C]// Computer Vision and Pattern Recognition. CVPR 2013. IEEE Conference on. IEEE, 2013, 38: 1155-1162.  
> [12]	Shi J, Yan Q, Xu L, et al. Hierarchical Saliency Detection on Extended CSSD[J]. IEEE Transactions on Pattern Analysis & Machine Intelligence, 2014, 38(4):717.  
> [13]	Cheng M M, Mitra N J, Huang X, et al. Global Contrast Based Salient Region Detection[J]. IEEE Transactions on Pattern Analysis and Machine Intelligence, 2015, 37(3):569-582.  
> [14]	Jiang H, Yuan Z, Cheng M M, et al. Salient Object Detection: A Discriminative Regional Feature Integration Approach[J]. International Journal of Computer Vision, 2017, 123(2):251-268.  
