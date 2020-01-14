source /home/saluser/repos/ts_sal/setup.env

pip install -e .

echo HERE
make_idl_files.py ATAOS ATArchiver ATBuilding ATCamera ATDome ATDomeTrajectory ATHeaderService ATHexapod ATMCS ATMonochromator ATPneumatics ATPtg ATSpectrograph ATTCS ATWhiteLight CBP CCArchiver CCCamera CCHeaderService CatchupArchiver DIMM DSM Dome EAS EFD EFDTransformationServer Electrometer Environment FiberSpectrograph GenericCamera HVAC Hexapod IOTA LOVE LinearStage MTAOS MTArchiver MTCamera MTDomeTrajectory MTEEC MTGuider MTHeaderService MTLaserTracker MTM1M3 MTM1M3TS MTM2 MTMount MTPtg MTTCS MTVMS PointingComponent PromptProcessing Rotator Scheduler Script ScriptQueue SummitFacility Test TunableLaser Watcher

python setup.py sdist
cd dist
pip install *.tar.gz
