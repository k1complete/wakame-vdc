# -*- coding: utf-8 -*-

module Dcmgr
  module Helpers
    module NicHelper
      def find_nic(ifindex = 2)
        ifindex_map = {}
        Dir.glob("/sys/class/net/*/ifindex").each do |ifindex_path|
          device_name = File.split(File.split(ifindex_path).first)[1]
          ifindex_num = File.readlines(ifindex_path).first.strip
          ifindex_map[ifindex_num] = device_name
        end
        #p ifindex_map
        ifindex_map[ifindex.to_s]
      end

      def nic_state(if_name = 'eth0')
        operstate_path = "/sys/class/net/#{if_name}/operstate"
        if File.exists?(operstate_path)
          File.readlines(operstate_path).first.strip
        end
      end

      def valid_nic?(nic)
        ifindex_path = "/sys/class/net/#{nic}/ifindex"
        if FileTest.exist?(ifindex_path)
          true
        else
          logger.warn("#{nic}: error fetching interface information: Device not found")
          false
        end
      end
    end
  end
end