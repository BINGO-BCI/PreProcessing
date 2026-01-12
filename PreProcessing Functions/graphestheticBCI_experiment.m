clear all
close all
imgcross=imread('cross.png');
img00=imread('rotation.png');
img01=imread('rotation_hand.png');
img10=imread('up.png');
img11=imread('up_hand.png');
img20=imread('left.png');
img21=imread('left_hand.png');
%lib = lsl_loadlib();
%info = lsl_streaminfo(lib,'MyMarkerStream3','Markers',1,0,'cf_string','myuniquesourceid23443');
%outlet = lsl_outlet(info);
trial_duration=5;% Duration of each trial
no_trials=20;% Number of trials for each condition
tmp_trial=[zeros(1,no_trials) ones(1,no_trials) 2*ones(1,no_trials) 3*ones(1,no_trials) 4*ones(1,no_trials) 5*ones(1,no_trials)];
trial_perm=randperm(length(tmp_trial));
trial_seq=tmp_trial(trial_perm);% Random Trial Sequense

%% Create Beep Sound
ts=1/8000;
T=0.1 %Beep Duration
t=0:ts:T; % Time Variable
y=sin(2*pi*400*t); %Pure Sin Sound

%% Run the Experiment
pause(15)
for i=1:length(trial_seq)
    i
    imshow(imgcross)
    pause(2+randi(3))
    sound(y, 16000)
    pause(1)
    if trial_seq(i)==0 %Rotation Trials - No hand
        imshow(img00)
        %outlet.push_sample({convertStringsToChars('00')});
        pause(trial_duration)
        sound(y, 4000)
    elseif trial_seq(i)==1 %Up Trials - No hand
        imshow(img10)
       % outlet.push_sample({convertStringsToChars('10')});
        pause(trial_duration)
        sound(y, 4000)
    elseif trial_seq(i)==2 %Left Trials - No Hand
        imshow(img20)
      %  outlet.push_sample({convertStringsToChars('20')});
        pause(trial_duration)
        sound(y, 4000)
    elseif trial_seq(i)==3 %Rotation Trials - No Hand
        imshow(img01)
        %outlet.push_sample({convertStringsToChars('01')});
        pause(trial_duration)
        sound(y, 4000)
    elseif trial_seq(i)==4 %Up Trials - No Hand
        imshow(img11)
       % outlet.push_sample({convertStringsToChars('11')});
        pause(trial_duration)
        sound(y, 4000)
    elseif trial_seq(i)==5 %Left Trials - No Hand
        imshow(img21)
        %outlet.push_sample({convertStringsToChars('21')});
        pause(trial_duration)
        sound(y, 4000)
    end
end
