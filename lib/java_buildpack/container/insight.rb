# Encoding: utf-8
# Copyright 2013 the original author or authors.

module JavaBuildpack::Insight

  # HTTP = 'http://'

  INSIGHT_AGENT_PATH = 'services/config/agent-download'

  INSIGHT_JAR_NAME = "insight-agent.jar"

  DOWNLOAD_DIR = 'tmp/'

  JAVA_BINARY = '/bin/java'

  #
  # Look for insight service in vcap_services and
  # return the dashboard host address if found
  #
  def find_insight(vcap_services)

    dashboard_address = nil
    insight = vcap_services.keys.find { |key| key =~ /insight/ }
    if insight
      details = vcap_services[insight]
      dashboard_address = details[0]['credentials']['dashboard_url']
    end

    return dashboard_address

  end

  #
  # Check if the insight service has been requested, if so
  # run the java jar insight-agent installer against the container home
  # Should be called by a container as part of the compile phase
  #
  # vcap_services - bound services from env
  # java_home - java home directory used to launch java binary
  # container_home - root directory to the container, the insight installer
  #  detects the container type and installs the agent appropriately
  #
  def install_insight_agent(vcap_services, java_home, container_home)

    return if  vcap_services.nil?  || java_home.nil? || container_home.nil?
    dashboard_address = find_insight(vcap_services)
    if dashboard_address
      download_install_insight_agent(dashboard_address, java_home, container_home)
    end

  end

  #
  # Downloads the insight installer from the dashboard it has been bound to.
  # If successful, it runs the installer to inject the insight agent into the container
  #
  # dashboard_address - host name of the dashboard
  # java_home - where an installed JRE is located so we can run java
  # container_home - path to the container, the insight installer detects the container type
  #                  and installs the insight agent appropriately
  #
  def download_install_insight_agent(dashboard_address, java_home, container_home)

    dashboard_agent_uri = dashboard_address +  INSIGHT_AGENT_PATH
    print "-----> Downloading Insight Agent from: #{dashboard_agent_uri}\n"
    JavaBuildpack::Util.download('Insight Agent', dashboard_agent_uri, 'Insight Agent', INSIGHT_JAR_NAME, DOWNLOAD_DIR)
    installer_jar = DOWNLOAD_DIR + INSIGHT_JAR_NAME
    if File.exists?(installer_jar)
      run_insight_installer(installer_jar, dashboard_address, java_home, container_home)
    else
      print "-----> Unable to download Insight Agent from: #{dashboard_agent_uri}\n"
    end

  end

  #
  # Actually runs the insight agent installer against the container
  #
  # installer_jar - path to the downloaded installer jar
  # dashboard_address - host name of the dashboard
  # java_home - where an installed JRE is located so we can run java
  # container_home - path to the container, the insight installer detects the container type
  #                  and installs the insight agent appropriately
  #
  def run_insight_installer(installer_jar, dashboard_address, java_home, container_home)

    java_bin = java_home + JAVA_BINARY
    if File.exists?(java_bin) && File.exists?(container_home)
      # print "-----> Using java from: #{java_bin}\n"
      print "-----> Installing Insight Agent: #{java_bin} -jar #{installer_jar} --path #{container_home} --http_host #{dashboard_address} --install\n"
      system("#{java_bin} -jar #{installer_jar} --path #{container_home} --http_host #{dashboard_address} --install")
      print "-----> Insight Agent installed\n"
    else
      print "-----> Unable to run Insight Agent installer, no Java or Container found!\n"
    end

  end
end
