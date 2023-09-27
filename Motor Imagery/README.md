# Motor Imagery BCI

For the Motor Imagery BCI, the State-Of-The-Art model thats widely being used is the Common-Spatial-Pattern Algorithm. The original CSP algorithm is implemented with several variations for feature extraction.

> Make sure to check each code carefully. A fairly good machine learning process is developed for feature extraction, feature selection and classification process.

Available Algorithms:

1. [Common Spatial Pattern **(CSP)**](1.%20CSP/)
2. [Filter Bank CSP **(FBCSP)**](2.%20FBCSP/)
3. [**Multi-Class CSP**](3.%20MultiClass-CSP/)
4. [Common Spation-Spectral Pattern **(CSSP)**](4.%20CSSP/)
5. [Regularized Common Spatial Pattern **(RCSP)**](5.%20RCSP/)

To improve the **Temporal Resolution**, 3 famous **source localization filters** are implemented:

1. Common Average Reference **(CAR)**
2. **Low Laplacian**
3. **High Laplacian**

**Tested datasets:**

1. [BCI Competition IV](https://www.bbci.de/competition/iv/)
2. [BCI Competition IV a](https://www.bbci.de/competition/iii/desc_IVa.html)
3. [BCI Competition IV 2a](https://www.bbci.de/competition/iv/)

---

### Biblography

[1] [Xinyang Yu, Pharino Chum, Kwee-Bo Sim, Analysis the effect of PCA for feature reduction in non-stationary EEG based motor imagery of BCI system](https://www.sciencedirect.com/science/article/abs/pii/S0030402613012473)

[2] [Yijun Wang, Shangkai Gao, Xiaorong Gao, Common Spatial Pattern Method for Channel Selelction in Motor Imagery Based Brain-computer Interface](https://ieeexplore.ieee.org/document/1615701)

[3] [Kai Keng Ang, Zheng Yang Chin, Chuanchu Wang, Cuntai Guan, Haihong Zhang, Filter bank common spatial pattern algorithm on BCI competition IV Datasets 2a and 2b](https://www.frontiersin.org/articles/10.3389/fnins.2012.00039/full)

[4] [Steven Lemm, Benjamin Blankertz, Gabriel Curio, and Klaus-Robert Müller, Spatio-Spectral Filters for Improving the Classification of Single Trial EEG](https://ieeexplore.ieee.org/document/1495698)

[5] [Fabien Lotte, Cuntai Guan, Regularizing Common Spatial Patterns to Improve BCI Designs: Unified Theory and New Algorithms](https://ieeexplore.ieee.org/document/5593210)
