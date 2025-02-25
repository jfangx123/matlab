
工业仿真软件的注释和二次开发。

# 部署

使用部署脚本`deploy.m`将`matlab_2022b_win_run.zip`解压到仓库，同名文件跳过。


# 平台
平台支持语言：英语，部分支持：汉语、日语、韩语。
资源所在路径`resources/MATLAB/en{zh_CN}{ja_JP}{ko_KR}`

# 定制

## 关闭使用.m文件替换后的警告
```
warning('query','last')
```
显示p文件所在目录包含m文件所对应的警告信息
```
identifier: 'MATLAB:pfileOlderThanMfile'
state: 'on'
```
关闭警告
```
warning('off', 'MATLAB:pfileOlderThanMfile')
```

## 增加新示例
1. 根据文档中的打开示例的命令（如：`openExample('sl3d/CreateActorInWorldSceneExample')`在新版本软件中打开并找到`.mlx`文件；
2. 复制到示例目录下，如`{matlab_root}\examples\sl3d\main`（注：文件名不修改）；
3. 在`{matlab_root}\examples\sl3d\examples.xml`中增加示例的元信息；
4. 使用命令进行测试。
```shell
openExample('sl3d/CreateActorInWorldSceneExample
```


## 设置支持包的根路径
Matlab 运行时的外部路径包括：
```shell
matlabshared.supportpkg.getSupportPackageRoot

% 用户的工作空间：{matlabroot}\software\matlab_utils\SupportPackages\R2022b
% 包括打开例子时拷贝的路径
userpath
% matlab 启动时的用户自定义配置的路径
```

## 附加文件
其他附件的文件包括支持包`SupportPackages`、软件`software`、示例`../demo`等。

### 支持包
量子计算
```shell
{matlab_root}\SupportPackages\toolbox\matlab\quantum
```


## 解码经验
脚本中出现`R36`表示声明函数参数验证，比如（`matlab\toolbox\shared\sim3d\sim3d\+sim3d\World.m`中的`setup()`）：
```shell
arguments
    self sim3d.World
    sampleTime(1,1) single{mustBePositive}
end
```

## 维护

### 覆盖本地的文件
```shell
git fetch --all
git reset --hard origin/master  # 将本地仓库的HEAD指针、工作目录和暂存区回滚到指定远程分支（origin/master）的状态
```

# 计划

编程实现.mlx中清除输出结果；

界面快捷键：Alt+D选中地址栏；

虚拟机中测试环境搭建；


# 参考
## 工具
[颜色命名器](https://products.aspose.app/svg/zh/color-names) 

## 更新
[新版本所加的特性](https://ww2.mathworks.cn/help/driving/release-notes.html)

2023a新增加的例子
```commandline
openExample('driving/CreateTopDownVisualizationDuringAnUnrealEngineSimulationExample')
openExample('scenariobuilder/EgoVehicleLocalizationUsingGPSAndIMUFusionExample')
openExample('scenariobuilder/EgoLocalizationUsingLaneDetectionsAndHDMapExample')
openExample('scenariobuilder/GenerateRoadSceneWithLanesFromLabeledRecordedDataExample')
openExample('driving_fusion_scenariobuilder/FuseRecordedLidarAndCameraDataForScenarioGenerationExample')
openExample('autonomous_control/TranslocateRoadRunnerCollisionScenarioToSelectedSceneExample')
openExample('driving/SetDefaultBasemapForHEREHDLiveMapLayerDataExample')
openExample('shared_vision_driving/PathPlanningUsing3DLidarMapExample')
openExample('autonomous_control/LaneLevelPathPlanningWithRRScenarioExample')
openExample('autonomous_control/PlatooningWithRRScenarioExample')
openExample('autonomous_control/AEBWithHighFidelityDynamicsExample')
```
深度学习
```commandline
openExample('deeplearning_shared/WorkWithDeepLearningDataInAzureBlobStorageExample')
openExample('nnet/SequenceClassificationCustomTrainingLoopExample')
openExample('nnet/OutofDistributionDetectionForDeepNeuralNetworksExample')
https://github.com/matlab-deep-learning/quantization-aware-training
openExample('deeplearning_shared/OutofDistributionDiscriminatorForYOLOV4ObjectDetectorExample')
openExample('deeplearning_shared/ExploreQuantizedSemanticSegmentationNetworkUsingGradCAMExample')
openExample('deeplearning_shared/QuantizeNetworkTrainedForSemanticSegmentationExample')
https://ww2.mathworks.cn/help/deeplearning/ug/detect-issues-while-training-deep-neural-network.html
openExample('deeplearning_shared/DetectPCBDefectsUsingYOLOV4Example')
openExample('images_deeplearning/CardiacLeftVentricleSegmentationFromCineMRIImagesExample')
```

