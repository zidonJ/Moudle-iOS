desc 'Deploy a new version to the App Store'
lane :do_deliver_app do |options|
  ENV["FASTLANE_PASSWORD"] = options[:itc_password]
  project          = options[:project]
  scheme           = options[:scheme]
  version          = options[:version] 
  build            = options[:build] || Time.now.strftime('%Y%m%d%H%M')
  output_directory = options[:output_directory]
  output_name      = options[:output_name]
    
  hipchat(message: "Start deilver app #{project} at version #{version}")
    
  hipchat(message: "Git pull")
  git_pull

  hipchat(message: "Pod install")
  cocoapods
   
  hipchat(message: "Update build number to #{build} and building ipa")
  update_build_number(version: build, plist: "#{project}/Info.plist")
  gym(scheme: options[:scheme], clean: true, output_directory: output_directory, output_name: output_name)

  hipchat(message: 'deliver to itunesconnect')
  deliver(force: false, skip_screenshots: true, skip_metadata: true)

  hipchat(message: "Upload #{project} to itunesconnect successfully!")
    
  git_add(path: '.')
  git_commit(path: '.', message: "update build number to #{build} and upload to itunesconnect")
  git_pull
  git_push(branch: "ios_dev")
end