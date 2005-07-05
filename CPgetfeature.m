function [ObjectTypename,FeatureType,FeatureNbr,SuffixNbr] = CPgetfeature(handles,Suffix)
%
%   This function takes the user through three list dialogs where a
%   specific feature is chosen. It is possible to go back and forth
%   between the list dialogs. The chosen feature can be identified
%   via the output variables as
%   handles.Measurements.(ObjectTypename).(FeatureType){FeatureNbr}
%   Empty variables will be returned if the cancel button is pressed.
%
%   The input variable 'suffix' is a cell array containing strings of
%   suffixes to look for. The currently used suffixes are 'Features' and
%   'Text'. If ommitted, the default is to look for suffix 'Features'.

if nargin < 2
    Suffix = {'Features'}
end

%%% Quick check if it seems to be a CellProfiler file or not
if ~isfield(handles,'Measurements')
    errordlg('The selected file does not contain any measurements.')
    ObjectTypename = [];FeatureType = [];FeatureNbr = [];
    return
end

%%% Extract the fieldnames of measurements from the handles structure.
MeasFieldnames = fieldnames(handles.Measurements);

%%% Error detection.
if isempty(MeasFieldnames)
    errordlg('No measurements were found.')
    ObjectTypename = [];FeatureType = [];FeatureNbr = [];
    return
end

dlgno = 1;                            % This variable keeps track of which list dialog is shown
while dlgno < 4
    switch dlgno
        case 1
            [Selection, ok] = listdlg('ListString',MeasFieldnames, 'ListSize', [300 400],...
                'Name','Select measurement',...
                'PromptString','Choose an object type',...
                'CancelString','Cancel',...
                'SelectionMode','single');
            if ok == 0
                ObjectTypename = [];FeatureType = [];FeatureNbr = [];
                return
            end
            ObjectTypename = MeasFieldnames{Selection};

            % Get all fields with the supplied suffix
            FeatureTypes = fieldnames(handles.Measurements.(ObjectTypename));
            SuffixNbr = [];
            tmp = {};
            for k = 1:length(FeatureTypes)
                for j = 1:length(Suffix)
                    if length(FeatureTypes{k}) > length(Suffix{j})
                        if strcmp(FeatureTypes{k}(end-length(Suffix{j})+1:end),Suffix{j})
                            SuffixNbr(end+1) = j;
                            tmp{end+1} = FeatureTypes{k}(1:end-length(Suffix{j}));    % Remove the suffix
                        end
                    end
                end
            end
            FeatureTypes = tmp;
            dlgno = 2;                      % Indicates that the next dialog box is to be shown next
        case 2
            [Selection, ok] = listdlg('ListString',FeatureTypes, 'ListSize', [300 400],...
                'Name','Select measurement',...
                'PromptString',['Choose a feature type for ', ObjectTypename],...
                'CancelString','Back',...
                'SelectionMode','single');
            if ok == 0
                dlgno = 1;                  % Back button pressed, go back one step in the menu system
            else
                FeatureType = FeatureTypes{Selection};
                SuffixNbr = SuffixNbr(Selection);
                Features = handles.Measurements.(ObjectTypename).([FeatureType Suffix{SuffixNbr}]);
                dlgno = 3;                  % Indicates that the next dialog box is to be shown next
            end
        case 3
            [Selection, ok] = listdlg('ListString',Features, 'ListSize', [300 400],...
                'Name','Select measurement',...
                'PromptString',['Choose a ',FeatureType,' of ', ObjectTypename],...
                'CancelString','Back',...
                'SelectionMode','single');
            if ok == 0
                dlgno = 2;                  % Back button pressed, go back one step in the menu system
            else
                FeatureNbr = Selection;
                dlgno = 4;                  % dlgno = 4 will exit the while-loop
            end
    end
end