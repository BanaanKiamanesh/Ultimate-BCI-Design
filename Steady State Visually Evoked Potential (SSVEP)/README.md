# Steady State Visually Evoked Potential

For the SSVEP based BCI, the State-Of-The-Art model thats widely being used is the **Canonical-Correlation-Analysis(CCA) Algorithm**. The original CCA algorithm is implemented with several variations for stimulation frequency detection.

Available Algorithms:

1. [Power Spectrum Density **(PSD)**](1.%20PSD/)
2. [Canonical Correlation Analysis **(CCA)**](2.%20CCA/)
3. [Multi-Variate Syychroniation Index **(MSI)**](3.%20MSI/)
4. [Fusion Canonical Correlation Analysis **(FoCCA)**](4.%20FoCCA/)
5. [Filter-Bank Canonical Correlation Analysis **(FBCCA)**](5.%20FBCCA/)
6. [CCA Feature Extraction with Machine Learning](6.%20CCA%20-%20ML/)

To improve the **Temporal Resolution**, Common-Average-Reference (CAR) **source localization filter** is implemented.

**Tested datasets:**

1. [LED SSVEP Dataset](https://github.com/sylvchev/dataset-ssvep-led)

---

### Biblography

[1] [S. M. Fernandez Fraga , M.A. Aceves-Fernandez , J.C. Pedraza Ortega and S. Tovar Arriaga, EEG Signal Analysis Methods Based on Steady State Visual Evoked Potential Stimuli for the Development of Brain Computer Interfaces: A Review](https://www.primescholars.com/abstract/eeg-signal-analysis-methods-based-onsteady-state-visual-evoked-potentialstimuli-for-the-development-of-braincomputer-int-92616.html)

[2] [Zhonglin Lin, Changshui Zhang, Wei Wu, and Xiaorong Gao, Frequency Recognition Based on Canonical Correlation Analysis for SSVEP-Based BCIs](https://ieeexplore.ieee.org/document/4203016)

[3] [Yangsong Zhang, Peng Xu, Kaiwen Cheng, Dezhong Yao, Multivariate synchronization index for frequency recognition of SSVEP-based brain–computer interface](https://www.sciencedirect.com/science/article/abs/pii/S0165027013002677)

[4] [TIEJUN LIU, YANGSONG ZHANG, LU WANG, JIANFU LI, PENG XU, DEZHONG YAO,  Fusing Canonical Coefficients for Frequency Recognition in SSVEP-Based BCI](https://ieeexplore.ieee.org/document/8692441)

[5] [Xiaogang Chen, Yijun Wang, Shangkai Gao, Tzyy-Ping Jung and Xiaorong Gao, Filter bank canonical correlation analysis for implementing a high-speed SSVEP-based brain–computer interface](https://iopscience.iop.org/article/10.1088/1741-2560/12/4/046008)
