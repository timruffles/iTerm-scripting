require 'rubygems'
require 'appscript'
require 'yaml'
include Appscript

iterm = app("/Applications/iTerm.app")

new_term = iterm.make(:new => :terminal)


# just normal yaml, keys in sessions become terminal titles (tho they often get overwritten :/)
# pop extra commands to be run after you merge with any common commands you want (hash as yaml can't merge lists)
sessions_setup = YAML.load <<-YAML
connection_commands: &conn
  1: ssh root@127.0.0.1 -p 2222
  2: cd /Development/Cothink/bizdiary-rails2

sessions:
  VM Spec: &shared
    background_color: blue
    bold_color: white
    cursor_color: white
    cursor_text_color: white
    foreground_color: white
    selected_text_color: red
    selection_color: black
    commands:
      <<: *conn
  VM Spork:
    <<: *shared
    commands:
      <<: *conn
      3: spork
  VM Server:
    <<: *shared
    commands:
      <<: *conn
      3: script/server
  VM Console:
    <<: *shared
    commands:
      <<: *conn
      3: script/console
YAML

sessions_setup['sessions'].each_pair do |title, setup|
  new_term.launch_(:session => title)
  session = new_term.sessions.last
  iterm.select(session)
  
  # retrieve commands
  commands = setup.delete('commands')
  
  setup.each_pair do |key, value|
    (session.send key).send :set, value
  end
  session.exec(:command => 'bash')
  commands.each_value do |cmd|
    session.write(:text => cmd)
  end
  
  session.name.set title
end
