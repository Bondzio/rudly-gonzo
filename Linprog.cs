classdef (Sealed) Linprog < optim.options.MultiAlgorithm
%

%Linprog Options for LINPROG
%
%   The OPTIM.OPTIONS.LINPROG class allows the user to create a set of
%   options for the LINPROG solver. For a list of options that can be set,
%   see the documentation for LINPROG.
%
%   OPTS = OPTIM.OPTIONS.LINPROG creates a set of options for LINPROG
%   with the options set to their default values.
%
%   OPTS = OPTIM.OPTIONS.LINPROG(PARAM, VAL, ...) creates a set of options
%   for LINPROG with the named parameters altered with the specified
%   values.
%
%   OPTS = OPTIM.OPTIONS.LINPROG(OLDOPTS, PARAM, VAL, ...) creates a copy
%   of OLDOPTS with the named parameters altered with the specified values.
%
%   See also OPTIM.OPTIONS.MULTIALGORITHM, OPTIM.OPTIONS.SOLVEROPTIONS

%   Copyright 2012-2018 The MathWorks, Inc.

    properties (Dependent)

%CONSTRAINTTOLERANCE Tolerance on the constraint violation.
%
%   For more information, type "doc linprog" and see the "Options" section
%   in the LINPROG documentation page.
        ConstraintTolerance

%DISPLAY Level of display
%
%   For more information, type "doc linprog" and see the "Options" section
%   in the LINPROG documentation page.
        Display

%MAXTIME Maximum time allowed
%
%   For more information, type "doc linprog" and see the "Options" section
%   in the LINPROG documentation page.
        MaxTime

%MAXITERATIONS Maximum number of iterations allowed
%
%   For more information, type "doc linprog" and see the "Options" section
%   in the LINPROG documentation page.
        MaxIterations

%OPTIMALITYTOLERANCE Termination tolerance on the first-order optimality
%                    measure
%
%   For more information, type "doc linprog" and see the "Options" section
%   in the LINPROG documentation page.
        OptimalityTolerance

    end

%------------------------ Old hidden properties ---------------------------

    properties (Hidden, Dependent)
%DIAGNOSTICS Display diagnostic information about the function
        Diagnostics

%MAXITER Maximum number of iterations allowed
        MaxIter

%PREPROCESS Preprocessing for the linear problems.
        Preprocess

%TOLCON Tolerance on the constraint violation.
        TolCon

%TOLFUN Termination tolerance on the function value
        TolFun

    end

    properties (Hidden, Access = protected)
%OPTIONSSTORE Contains the option values and meta-data for the class
%
        OptionsStore = createOptionsStore;
    end

    properties (Hidden)
%SOLVERNAME Name of the solver that the options are intended for
%
        SolverName = 'linprog';
    end

    properties (Hidden, SetAccess = private, GetAccess = public)

        %INTERNALOPTIONS Internal options (added in version 3)
        InternalOptions = struct();

        % New version property added in second version
        LinprogVersion
    end
    
    properties(Hidden, Constant, GetAccess=public)
% Constant, globally visible metadata about this class.
% This data is used to spec the options in this class for internal clients
% such as: tab-complete, and the options validation
% Properties
        PropertyMetaInfo = genPropInfo();    
    end

    methods (Hidden)

        function obj = Linprog(varargin)
%Linprog Options for LINPROG
%
%   The OPTIM.OPTIONS.LINPROG class allows the user to create a set of
%   options for the LINPROG solver. For a list of options that can be set,
%   see the documentation for LINPROG.
%
%   OPTS = OPTIM.OPTIONS.LINPROG creates a set of options for LINPROG
%   with the options set to their default values.
%
%   OPTS = OPTIM.OPTIONS.LINPROG(PARAM, VAL, ...) creates a set of options
%   for LINPROG with the named parameters altered with the specified
%   values.
%
%   OPTS = OPTIM.OPTIONS.LINPROG(OLDOPTS, PARAM, VAL, ...) creates a copy
%   of OLDOPTS with the named parameters altered with the specified values.
%
%   See also OPTIM.OPTIONS.MULTIALGORITHM, OPTIM.OPTIONS.SOLVEROPTIONS

            % Call the superclass constructor
            obj = obj@optim.options.MultiAlgorithm(varargin{:});

            % Record the class version; Update property 'LinprogVersion'
            % instead of superclass property 'Version'.
            obj.Version = 1;
            obj.LinprogVersion = 6;
        end

    end

    % Set/get methods
    methods

        % ---------------------- Set methods ------------------------------

        function obj = set.ConstraintTolerance(obj, value)
            obj = setAliasProperty(obj, 'ConstraintTolerance', 'TolCon', value);
        end

        function obj = set.Diagnostics(obj, value)
            obj = setProperty(obj, 'Diagnostics', value);
        end

        function obj = set.Display(obj, value)
            if strcmpi(value, 'testing')
                % Set Display to the undocumented value, 'testing'.
                obj = setPropertyNoChecks(obj, 'Display', 'testing');
            else
                % Pass the possible values that the Display option can take via
                % the fourth input of setProperty.
                obj = setProperty(obj, 'Display', value, ...
                    {'off','none','final', 'iter'});
            end
        end

        function obj = set.MaxIter(obj, value)
            obj = setProperty(obj, 'MaxIter', value);
        end

        function obj = set.MaxIterations(obj, value)
             obj = setAliasProperty(obj, 'MaxIterations', 'MaxIter', value);
        end

        function obj = set.MaxTime(obj, value)
            obj = setProperty(obj, 'MaxTime', value);
        end

        function obj = set.OptimalityTolerance(obj, value)
            obj = setAliasProperty(obj, 'OptimalityTolerance', 'TolFun', value);
        end

        function obj = set.Preprocess(obj, value)
            obj = setProperty(obj, 'Preprocess', value, ...
                {'none', 'basic'});
        end

        function obj = set.TolFun(obj, value)
            obj = setProperty(obj, 'TolFun', value);
        end

        function obj = set.TolCon(obj, value)
            obj = setProperty(obj, 'TolCon', value);
        end

        % ---------------------- Get methods ------------------------------

        function value = get.ConstraintTolerance(obj)
            value = obj.OptionsStore.Options.TolCon;
        end

        function value = get.Diagnostics(obj)
            value = obj.OptionsStore.Options.Diagnostics;
        end

        function value = get.Display(obj)
            value = obj.OptionsStore.Options.Display;
        end

        function value = get.MaxIterations(obj)
           value = obj.OptionsStore.Options.MaxIter;
        end

        function value = get.MaxIter(obj)
            value = obj.OptionsStore.Options.MaxIter;
        end

        function value = get.MaxTime(obj)
            value = obj.OptionsStore.Options.MaxTime;
        end

        function value = get.OptimalityTolerance(obj)
            value = obj.OptionsStore.Options.TolFun;
        end

        function value = get.Preprocess(obj)
            value = obj.OptionsStore.Options.Preprocess;
        end

        function value = get.TolCon(obj)
            value = obj.OptionsStore.Options.TolCon;
        end

        function value = get.TolFun(obj)
            value = obj.OptionsStore.Options.TolFun;
        end

    end

    methods (Hidden)

        function [obj, OptimsetStruct] = mapOptimsetToOptions(obj, OptimsetStruct)
%mapOptimsetToOptions Map optimset structure to optimoptions
%
%   obj = mapOptimsetToOptions(obj, OptimsetStruct) maps specified optimset
%   options, OptimsetStruct, to the equivalent options in the specified
%   optimization object, obj.
%
%   [obj, OptimsetStruct] = mapOptimsetToOptions(obj, OptimsetStruct)
%   additionally returns an options structure modified with any conversions
%   that were performed on the options object.

            % Set 'Algorithm' to 'dual-simplex' if 'LargeScale' is
            % empty or 'on' and 'Algorithm' is empty.
            lgScale = isfield(OptimsetStruct,'LargeScale') && ...
                (isempty(OptimsetStruct.LargeScale) || strcmpi(OptimsetStruct.LargeScale,'on'));
            defaultAlg = ~isfield(OptimsetStruct, 'Algorithm')  || ...
                (isfield(OptimsetStruct, 'Algorithm') && ...
                isempty(OptimsetStruct.Algorithm));
            if defaultAlg && lgScale
                obj.Algorithm = 'dual-simplex';
            end

            % Also modify the incoming structure.
            if nargout > 1
                OptimsetStruct.Algorithm = obj.Algorithm;
                if isfield(OptimsetStruct,'LargeScale')
                    OptimsetStruct = rmfield(OptimsetStruct,'LargeScale');
                end
                if isfield(OptimsetStruct,'Simplex')
                    OptimsetStruct = rmfield(OptimsetStruct,'Simplex');
                end
            end
        end

        function thisAlgorithm = createAlgorithm(obj)
%CREATEALGORITHM Create the algorithm from the options
%
%   THISALGORITHM = CREATEALGORITHM(OBJ) creates an instance of
%   optim.algorithm.LinprogDualSimplex from OBJ. The Options property
%   of THISALGORITHM is set to OBJ.
            switch obj.Algorithm
                case 'dual-simplex'
                    % Create the algorithm instance and pass the options
                    % object
                    thisAlgorithm = optim.algorithm.LinprogDualSimplex(obj);
                case 'interior-point'
                    % Create the algorithm instance and pass the options
                    % object
                    thisAlgorithm = optim.algorithm.LinprogInteriorPoint(obj);
                otherwise
                    % For now, there aren't classes for the other linprog
                    % algorithms
                    thisAlgorithm = [];
            end

        end

        function checkOptions(~, ~, ~)
%CHECKOPTIONS Perform consistency checks on the options
%
%   CHECKOPTIONS(OBJ, PROBLEM, CALLER) checks that the options are
%   consistent as a set (e.g. DiffMaxChange >= DiffMinChange for fmincon).
%   This function also checks that any options that are dependent on the
%   problem are valid.

%   For this options object, there are no options that depend on eachother
%   or the problem. So this function does not need to perform any action.

        end

        function obj = setInternalOptions(obj, InternalOptions)

%SETINTERNALOPTIONS Set internal SLBI options
%
%   OBJ = SETINTERNALOPTIONS(OBJ, INTERNALOPTIONS) sets the specified
%   internal options in OBJ

           obj.InternalOptions = InternalOptions;

        end

        function OptionsStruct = extractCustomOptionsStructure(obj)
%EXTRACTCUSTOMOPTIONSSTRUCTURE Extract options structure from OptionsStore
%
%   OPTIONSSTRUCT = EXTRACTCUSTOMOPTIONSSTRUCTURE(OBJ) extracts a plain
%   structure containing the options from obj.OptionsStore. The solver
%   calls convertForSolver, which in turn calls this method to obtain a
%   plain options structure.

            % Call the superclass method
            OptionsStruct = extractCustomOptionsStructure@optim.options.MultiAlgorithm(obj);

            % Append the InternalOptions field
            OptionsStruct.InternalOptions = obj.InternalOptions;

        end

    end

    % Load old objects
    methods (Static = true)
        function obj = loadobj(obj)

            % Objects saved in R2013a will come in as structures.
            if isstruct(obj) && obj.Version == 1

                % Save the existing structure
                s = obj;

                % Create a new object
                obj = optim.options.Linprog;

                % Call the superclass method to upgrade the object
                obj = upgradeFrom13a(obj, s);

                % The SolverVersion property was not present in 13a. We
                % clear it here and the remainer of loadobj will set it
                % correctly.
                obj.LinprogVersion = [];

            end

            % Introduce LinprogVersion field
            if isempty(obj.LinprogVersion)
                % Use 'LinprogVersion' property instead of 'Version' property
                % because 'Version' is for the superclass and 'LinprogVersion' is
                % for this (derived) class. However, 'LinprogVersion' was added in
                % the second version, we check only for the first version and
                % add this property. For all other version, check only the
                % 'LinprogVersion' property.
                obj.LinprogVersion = 1; % update object
            end

            % Upgrading to 14b
            if obj.LinprogVersion < 2
                % Update OptionsStore by taking the loaded OptionsStore and
                % add info for the dual-simplex algorithm
                os = createOptionsStore();
                os.SetByUser = obj.OptionsStore.SetByUser;
                os.SetByUser.MaxTime = false;
                os.SetByUser.TolCon = false;
                os.SetByUser.Preprocess = false;
                os.Options = obj.OptionsStore.Options;
                os.Options.MaxTime = os.AlgorithmDefaults{2}.MaxTime;
                os.Options.TolCon = os.AlgorithmDefaults{2}.TolCon;
                os.Options.Preprocess = os.AlgorithmDefaults{2}.Preprocess;
                obj.OptionsStore = os;
            end

            % Upgrading to 15b
            if obj.LinprogVersion < 3
                % Add InternalOptions field. MATLAB will handle this.

                % Update OptionsStore by taking the loaded OptionsStore and
                % add info for the new interior-point algorithm
                os = createOptionsStore();
                os.SetByUser = obj.OptionsStore.SetByUser;
                os.Options = obj.OptionsStore.Options;
                obj.OptionsStore = os;

                % TolCon is now used by the dual-simplex and interior-point
                % algorithms. If TolCon is not set, it should be set to the
                % default value for 'interior-point', which is NaN as it
                % isn't defined.
                if ~isSetByUser(obj, 'TolCon')
                    obj.OptionsStore.Options.TolCon = NaN;
                end

                % Algorithm value 'interior-point' from 15a has been mapped
                % to 'interior-point-legacy' in 15b.
                if strcmp(obj.OptionsStore.Options.Algorithm, 'interior-point')
                    if isSetByUser(obj, 'Algorithm')
                        % Reset Algorithm to 'interior-point' to correct
                        % the value of options not set by user
                        obj.Algorithm = 'interior-point';
                    else
                        % Need to upgrade the options value if it has not been
                        % set by the user.
                        obj.OptionsStore.Options.Algorithm = 'interior-point-legacy';
                    end
                end
            end

            % Upgrading to 16a
            % Add NumDisplayOptions and DisplayOptions fields
            if obj.LinprogVersion < 4
                obj.OptionsStore = optim.options.getDisplayOptionFieldsFor16a(...
                    obj.OptionsStore, getDefaultOptionsStore);
            end

            % Upgrading to 16b
            % Remove 'simplex' and 'active-set' algorithms
            if obj.LinprogVersion < 5
                % Create new options store and swap set by user values?
                if obj.OptionsStore.SetByUser.Algorithm && ...
                        (strcmpi(obj.OptionsStore.Options.Algorithm, 'active-set') || ...
                         strcmpi(obj.OptionsStore.Options.Algorithm, 'simplex'))
                    % links to context sensitive help
                    [linkTag,endLinkTag] = linkToAlgDefaultChangeCsh('linprog_warn_will_error');
                    warning(message('optim:options:Linprog:SimplexActiveSetRemovedSwitch',...
                                    lower(obj.OptionsStore.Options.Algorithm), ...
                                    obj.OptionsStore.DefaultAlgorithm, ...
                                    linkTag, endLinkTag));
                    obj = obj.resetoptions('Algorithm');
                end
                newOpts = optim.options.Linprog;
                os = createOptionsStore();
                allOptions = fieldnames(os.Options);
                for k = 1:numel(allOptions)
                    if obj.OptionsStore.SetByUser.(allOptions{k})
                        newOpts.(allOptions{k}) = obj.(allOptions{k});
                    end
                end
                obj = newOpts;
            end
            
            % Upgrading to 17a
            % If the algorithm is not set, switch to the new default
            % algorithm: dual-simplex
            if obj.LinprogVersion < 6
                % Change the default in the OptionsStore
                obj.OptionsStore.DefaultAlgorithm = 'dual-simplex';

                % If the user hasn't set the Algorithm option, keep the
                % saved value of Algorithm.
                if ~obj.OptionsStore.SetByUser.Algorithm
                    obj = setPropertyNoChecks(obj, ...
                        'Algorithm', 'interior-point-legacy');
                end               

            end
            
            % Set the version number
            obj.LinprogVersion = 6;
        end
    end
end

function OS = createOptionsStore
%CREATEOPTIONSSTORE Create the OptionsStore
%
%   OS = createOptionsStore creates the OptionsStore structure. This
%   structure contains the options and meta-data for option display, e.g.
%   data determining whether an option has been set by the user. This
%   function is only called when the class is first instantiated to create
%   the OptionsStore structure in its default state. Subsequent
%   instantiations of this class pick up the default OptionsStore from the
%   MCOS class definition.
%
%   Class authors must create a structure containing the following fields:-
%
%   AlgorithmNames   : Cell array of algorithm names for the solver
%   DefaultAlgorithm : String containing the name of the default algorithm
%   AlgorithmDefaults: Cell array of structures. AlgorithmDefaults{i}
%                      holds a structure containing the defaults for
%                      AlgorithmNames{i}.
%
%   This structure must then be passed to the
%   optim.options.generateMultiAlgorithmOptionsStore function to create
%   the full OptionsStore. See below for an example for Linprog.

% Define the algorithm names
OS.AlgorithmNames = {'interior-point-legacy', 'dual-simplex', 'interior-point'};

% Define the default algorithm
OS.DefaultAlgorithm = 'dual-simplex';

% Define the defaults for each algorithm
% interior-point-legacy
OS.AlgorithmDefaults{1}.Diagnostics = 'off';
OS.AlgorithmDefaults{1}.Display = 'final';
OS.AlgorithmDefaults{1}.MaxIter = 85;
OS.AlgorithmDefaults{1}.TolFun = 1e-8;

% dual-simplex
OS.AlgorithmDefaults{2}.Diagnostics = 'off';
OS.AlgorithmDefaults{2}.Display = 'final';
OS.AlgorithmDefaults{2}.MaxIter = '10*(numberOfEqualities+numberOfInequalities+numberOfVariables)';
OS.AlgorithmDefaults{2}.MaxTime = Inf;
OS.AlgorithmDefaults{2}.Preprocess = 'basic';
OS.AlgorithmDefaults{2}.TolCon = 1e-4;
OS.AlgorithmDefaults{2}.TolFun = 1e-7;

% interior-point
OS.AlgorithmDefaults{3}.Diagnostics = 'off';
OS.AlgorithmDefaults{3}.Display = 'final';
OS.AlgorithmDefaults{3}.MaxIter = 200;
OS.AlgorithmDefaults{3}.TolCon = 1e-6;
OS.AlgorithmDefaults{3}.TolFun = 1e-6;

% Call the package function to generate the OptionsStore
OS = optim.options.generateMultiAlgorithmOptionsStore(OS, 'optim.options.Linprog');

end

function os = getDefaultOptionsStore

persistent thisos

if isempty(thisos)
    opts = optim.options.Linprog;
    thisos = getOptionsStore(opts);
end
    
os = thisos;

end

function propInfo = genPropInfo()
% Helper function to generate constant property metadata for the Linprog
% options class.
import optim.internal.TypeInfo
propInfo.Algorithm = TypeInfo.enumType({'dual-simplex','interior-point-legacy','interior-point'});
propInfo.ConstraintTolerance = TypeInfo.numericType();
propInfo.Display = TypeInfo.enumType({'final','off','iter'});
propInfo.MaxIterations = TypeInfo.integerType();
propInfo.MaxTime = TypeInfo.numericType();
propInfo.OptimalityTolerance = TypeInfo.numericType();
end