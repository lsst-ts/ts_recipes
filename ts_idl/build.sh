export TS_IDL_DIR=$SRC_DIR
source /home/saluser/repos/ts_sal/setup.env
make_idl_files.py ATAOS \
    ATArchiver\
    ATBuilding\
    ATCamera\
    ATDome\
    ATDomeTrajectory \
    ATHeaderService\
    ATHexapod\
    ATMCS\
    ATMonochromator\
    ATPneumatics\
    ATPtg\
    ATSpectrograph\
    ATTCS\
    ATWhiteLight\
    CBP\
    CatchupArchiver\
    DIMM\
    Dome\
    EAS\
    EFD\
    EFDTransformationServer\
    Electrometer\
    Environment\
    FiberSpectrograph\
    GenericCamera\
    HVAC\
    Hexapod\
    IOTA\
    LinearStage\
    MTAOS\
    MTArchiver\
    MTCamera\
    MTDomeTrajectory\
    MTEEC\
    MTGuider\
    MTHeaderService\
    MTLaserTracker\
    MTM1M3\
    MTM1M3TS\
    MTM2\
    MTMount\
    MTPtg\
    MTTCS\
    MTVMS\
    OCS\
    PointingComponent\
    PromptProcessing\
    Rotator\
    Scheduler\
    Script\
    ScriptQueue\
    SummitFacility\
    Test\
    TunableLaser\
    Watcher
python setup.py sdist
cd dist
pip install ts_idl-${GIT_BUILD_STR}.tar.gz
