Training = csvread('CI_Assignment_TrainingData.csv' , 1 ,1)
trainingPrice = Training(:,3);
figure('name', 'Training Data with Outliers');
plot(trainingPrice, '*b')

Tr_Q1=prctile(trainingPrice,25);
Tr_Q3=prctile(trainingPrice,75);
trainingRange=[Tr_Q1-1.5*( Tr_Q3-Tr_Q1),Tr_Q3+1.5*(Tr_Q3-Tr_Q1)];
trainingPosition=[find(trainingPrice>trainingRange(2)) find(trainingPrice<trainingRange(1))];
trainingPrice(trainingPosition)=[];
figure('name','Training Data without Outliers');
plot(trainingPrice, '*r')

Training=removerows(Training, trainingPosition);

Testing = csvread('CI_Assignment_TestingData.csv' , 1 ,1)
testingPrice = Testing(:,3);
figure('name', 'Testing Data with Outliers');
plot(testingPrice, '*b')

Tr_Q1=prctile(testingPrice,25);
Tr_Q3=prctile(testingPrice,75);
testingRange=[Tr_Q1-1.5*( Tr_Q3-Tr_Q1),Tr_Q3+1.5*(Tr_Q3-Tr_Q1)];
testingPosition=[find(testingPrice>testingRange(2)) find(testingPrice<testingRange(1))];
testingPrice(testingPosition)=[];
figure('name','Testing Data without Outliers');
plot(testingPrice, '*r')


Testing=removerows(Testing, testingPosition);


%list the outliers

outliers_trainingPrice=csvread('CI_Assignment_TrainingData.csv',1,3);
outliers_testingPrice=csvread('CI_Assignment_TestingData.csv',1,3);
Tr_outliers = outliers_trainingPrice(trainingPosition);
Te_outliers = outliers_testingPrice(testingPosition);



% timer series

tr_T = Training(:,1);
tr_D = Training(:,2);
tr_P = Training(:,3);
tr_t=3:(length(Training)-1);
Training =[tr_T(tr_t-2),tr_T(tr_t-1),tr_T(tr_t),tr_D(tr_t-2),tr_D(tr_t-1),tr_D(tr_t),tr_P(tr_t+1)];
csvwrite('trainingTimeSeries.csv', Training)

te_T = Testing(:,1);
te_D = Testing(:,2);
te_P = Testing(:,3);
te_t=3:(length(Testing)-1);
Testing =[te_T(te_t-2),te_T(te_t-1),te_T(te_t),te_D(te_t-2),te_D(te_t-1),te_D(te_t),te_P(te_t+1)];
csvwrite('testingTimeSeries.csv', Testing)


testingCorrcoef = corrcoef(Testing)
trainingCorrcoef = corrcoef(Training)

trainingInput(:,1) = Training(:,1);
trainingInput(:,2) = Training(:,6);
trainingOutput = Training(:,7);

testingInput(:,1) = Testing(:,1);
testingInput(:,2) = Testing(:,6);
testingOutput = Testing(:,7);


hist(trainingInput(:,1))
title('Temperature');
hist(trainingInput(:,2))
title('Demand');
hist(trainingOutput(:,1))
title('Price');

fuzzSys= readfis('modelfuzzy.fis');
fuzzSys = mam2sug(fuzzSys);
futureprices = evalfis(trainingInputs,fuzzSys);
figure
n = 1:length(trainingInputs);
plot(n,trainingOutputs,n,futureprices)
xlabel('n')
ylabel('Prices')
title('Relationship between Training Output Prices with Predicted')
legend('Training Prices','Predicted Priced')
RErr = (sum((abs(futureprices - trainingOutputs))./futureprices))./length(futureprices)


fuzzSys= readfis('modelfuzzy.fis');
fuzzSys = mam2sug(fuzzSys);
futureprices = evalfis(testingInputs,fuzzSys);
figure
n = 1:length(testingInputs);
plot(n,testingOutputs,n,futureprices)
xlabel('n')
ylabel('Prices')
title('Relationship between Testing Output Prices with Predicted')
legend('Testing Prices','Predicted Priced')
RErr = (sum((abs(futureprices - testingOutputs))./futureprices))./length(futureprices)