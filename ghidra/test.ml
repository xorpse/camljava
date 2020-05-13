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

let () =
  let config = HeadlessConfig.create () in
  let layout = ApplicationLayout.create () in
  Application.initialize_application layout config;
  let project_dir = Jni.string_to_java "/tmp/test_project" in
  let project_name = Jni.string_to_java "test" in
  let program_name = Jni.string_to_java "/usr/bin/true" in
  let proj = Project.create project_dir project_name in
  let _ = Project.import proj program_name in
  print_endline "DONE!"
