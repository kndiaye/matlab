

load /tmp/epil/test/debcrise1-long_data_trial_1_MNE_MEGresults_1747.mat

StudySubject.Subject = 'bern_brainstormsubject.mat'
StudySubject.SubjectImage = 'bern_subjectimage.mat'
StudySubject.SubjectTess = 'tri/bern_Lwhite-CTF_tess.mat'
StudySubject.SubjectTriConn = []
StudySubject.SubjectVertConn = 'bern_Lwhite-CTF_tess_vertconn.mat'
StudySubject.Results = []


for STUDY=1:3


if STUDY==1
StudySubject.Study = 'deb1/debcrise1-long_brainstormstudy.mat'
StudySubject.Channel = 'deb1/debcrise1-long_channel.mat'
StudySubject.HeadModel = ''
StudySubject.Data = {'deb1/debcrise1-long_data_trial_0.mat'}
GUI.DataName='deb1/debcrise1-long_data_trial_0.mat'

r='deb1/debcrise1-long_data_trial_0_MNE_MEGresults.mat'
end

if STUDY==2
StudySubject.Study = 'deb2/debcrise2-long_brainstormstudy.mat'
StudySubject.Channel = 'deb2/debcrise2-long_channel.mat'
StudySubject.HeadModel = ''
StudySubject.Data = {'deb2/debcrise2-long_data_trial_0.mat'}
GUI.DataName='deb2/debcrise2-long_data_trial_0.mat'

r='deb2/debcrise2-long_data_trial_0_MNE_MEGresults.mat'
end

if STUDY==3
StudySubject.Study = 'deb3/debcrise3-long_brainstormstudy.mat'
StudySubject.Channel = 'deb3/debcrise3-long_channel.mat'
StudySubject.HeadModel = ''
StudySubject.Data = {'deb3/debcrise3-long_data_trial_0.mat'}
GUI.DataName='deb3/debcrise3-long_data_trial_0.mat'

r='deb3/debcrise3-long_data_trial_0_MNE_MEGresults.mat'
end

disp(sprintf('Saving... %s', r))

    % save(r, '-append', 'StudySubject')
 save(r, '-append', 'Comment', 'GUI')
end