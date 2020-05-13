#require "camljava"

module Application = struct
  let clazz = Jni.find_class "ghidra/framework/Application"

  let is_initialized_id = Jni.get_static_methodID clazz "isInitialized" "()Z"
  let initialize_application_id =
    Jni.get_static_methodID clazz
      "initializeApplication"
      "(Lutility/application/ApplicationLayout;Lghidra/framework/ApplicationConfiguration;)V"

  let is_initialized () =
    Jni.call_static_boolean_method clazz is_initialized_id [||]
  let initialize_application layout config =
    Jni.call_static_void_method clazz initialize_application_id [|Jni.Obj layout; Jni.Obj config|]
end

module HeadlessConfig = struct
  let clazz = Jni.find_class "ghidra/framework/HeadlessGhidraApplicationConfiguration"
  let init_id = Jni.get_methodID clazz "<init>" "()V"

  let create () =
    let obj = Jni.alloc_object clazz in
    Jni.call_void_method obj init_id [||];
    obj
end

module ApplicationLayout = struct
  let clazz = Jni.find_class "ghidra/GhidraJarApplicationLayout"
  let init_id = Jni.get_methodID clazz "<init>" "()V"

  let create () =
    let obj = Jni.alloc_object clazz in
    Jni.call_void_method obj init_id [||];
    obj
end

module File = struct
  let clazz = Jni.find_class "java/io/File"
  let init_id = Jni.get_methodID clazz "<init>" "(Ljava/lang/String;)V"

  let create path =
    let obj = Jni.alloc_object clazz in
    Jni.call_void_method obj init_id [|Jni.Obj path|];
    obj
end

module Project = struct
  let clazz = Jni.find_class "ghidra/base/project/GhidraProject"
  let create_project_id = Jni.get_static_methodID clazz "createProject" "(Ljava/lang/String;Ljava/lang/String;Z)Lghidra/base/project/GhidraProject;"
  let import_program_id = Jni.get_methodID clazz "importProgram" "(Ljava/io/File;)Lghidra/program/model/listing/Program;"

  let create ?(temp = false) path name =
    Jni.call_static_object_method
      clazz
      create_project_id
      [|Jni.Obj path; Jni.Obj name; Jni.Boolean temp|]

  let import proj file =
    let file' = File.create file in
    Jni.call_object_method proj import_program_id [|Jni.Obj file'|]

end

module TaskMonitor = struct
  let clazz = Jni.find_class "ghidra/util/task/TaskMonitor"
  let dummy_id = Jni.get_static_fieldID clazz "DUMMY" "Lghidra/util/task/TaskMonitor;"

  let dummy = Jni.get_static_object_field clazz dummy_id
end

module ProgramUtils = struct
  let clazz = Jni.find_class "ghidra/program/util/GhidraProgramUtilities"
  let set_analyzed_flag_id = Jni.get_static_methodID clazz "setAnalyzedFlag" "(Lghidra/program/model/listing/Program;Z)V"

  let set_analyzed_flag prog =
    Jni.call_static_void_method clazz set_analyzed_flag_id [|Jni.Obj prog; Jni.Boolean true|]
end

module AutoAnalysis = struct
  let clazz = Jni.find_class "ghidra/app/plugin/core/analysis/AutoAnalysisManager"
  let get_analysis_manager_id = Jni.get_static_methodID clazz "getAnalysisManager" "(Lghidra/program/model/listing/Program;)Lghidra/app/plugin/core/analysis/AutoAnalysisManager;"
  let reanalyze_all_id = Jni.get_methodID clazz "reAnalyzeAll" "(Lghidra/program/model/address/AddressSetView;)V"
  let start_analysis_id = Jni.get_methodID clazz "startAnalysis" "(Lghidra/util/task/TaskMonitor;)V"

  let analysis_manager prog =
    Jni.call_static_object_method clazz get_analysis_manager_id [|Jni.Obj prog|]
  let reanalyze_all mgr =
    Jni.call_void_method mgr reanalyze_all_id [|Jni.Obj Jni.null|]
  let start_analysis mgr =
    Jni.call_void_method mgr start_analysis_id [|Jni.Obj TaskMonitor.dummy|]
end

let () =
  let config = HeadlessConfig.create () in
  let layout = ApplicationLayout.create () in
  Application.initialize_application layout config;
  let project_dir = Jni.string_to_java "/tmp/test_project" in
  let project_name = Jni.string_to_java "test" in
  let program_name = Jni.string_to_java "/usr/bin/true" in
  let proj = Project.create project_dir project_name in
  let prog = Project.import proj program_name in
  let amgr = AutoAnalysis.analysis_manager prog in
  AutoAnalysis.reanalyze_all amgr;
  AutoAnalysis.start_analysis amgr;
  ProgramUtils.set_analyzed_flag prog;
  print_endline "DONE!"
