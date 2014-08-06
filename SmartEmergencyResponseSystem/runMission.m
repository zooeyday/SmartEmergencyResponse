% ******************************************************************************
% Copyright (c) 2014, The MathWorks, Inc. All rights reserved.

function runMission
    
    imData = imread('Copy_of_SFHiRes.png');
    [nodes, graph, deployment] = loadNodeDataFromMapFile('SanFrancisco.map');
    theaterXlim = [-122.459450, -122.381392];
    theaterYlim = [37.773665, 37.811574];

    GV = GroundVehicleManager(nodes);
    QC = QuadCopterManager;
    KU = KukaManager; 
    BB = BiobotManager;
    AT = AtlasManager;
    FW = FixedWingManager;
    
    RM = RequestManager;

    stationOptimizer = PathPlanner;
    quadcopterOptimizer = QuadrotorOptimizationDispatchAdaptor('127.0.0.1',...
                                                               10030,...
                                                               10020,...
                                                               RM,...
                                                               QC,...
                                                               GV);

    MIT = shAirConnection('',9527);
    addlistener(MIT,'validDatagramReceived',@newRequest);
    
    mainUI = missionUI(imData,...
                       nodes,...
                       RM,GV,QC,KU,BB,AT,FW,deployment,...
                       graph,...
                       stationOptimizer,quadcopterOptimizer,...
                       theaterXlim,theaterYlim);
    append(mainUI,'CloseRequestFcn',@cleanup);                   

    missionMap(imData,...
               nodes,...
               RM,GV,QC,KU,BB,AT,FW,deployment,...
               graph,...
               theaterXlim,theaterYlim);
    
    function newRequest(src,~)
        itemMap = {'Defibrillator';...
                   'Thermal Camera';...
                   'Stabilizer';...
                   'Sterile Band';...
                   'Thermal Blanket';...
                   'Thrombolytics';...
                   'Carbamazepine';...
                   'Oral Airway';...
                   'Endotracheal Tube';...
                   'Sensory Animal';...
                   'Robotic Arm';...
                   'Robot ATLAS'};
        isPickup = (src.lastValidData.pickupDropoff==2);
        RM.addRequest([src.lastValidData.latitude, src.lastValidData.longitude],...
                      ItemFactory.makeItem(itemMap{src.lastValidData.itemID}),...
                      'MIT shAir',...
                      src.lastValidData.priority,...
                      now,...
                      now,...
                      src.lastValidData.quantity,...
                      ~isPickup,...
                      isPickup);
    end

    function cleanup(src,~)
        delete(GV);
        delete(QC);
        delete(BB);
        delete(KU);
        delete(AT);
        delete(RM);
        delete(stationOptimizer);
        delete(quadcopterOptimizer);
        delete(MIT);
        if isvalid(src)
            delete(src);
        end
    end
end
