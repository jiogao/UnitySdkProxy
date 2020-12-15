# UnitySdkProxy Android

功能: 打包工程使用gradle脚本引用unity导出工程内的资源，sdk接入的代码，配置文件，和库等实现独立打包工程。

1.以基础打包工程为模板，每个需要接入的sdk复制一个独立的接入工程接入sdk和更改设置。

2.设置好打包工程设置好targetProjPath后，unity导出工程到指定路径下，使用打包工程导出apk。

3.SdkProxyProj_il2cppHotfixBase 是一个加上了热更新il2cpp.so功能的工程，
  使用的是这位大神的方案 https://github.com/noodle1983/UnityAndroidIl2cppPatchDemo-libboostrap