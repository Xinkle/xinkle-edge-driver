-- Zigbee konke Button
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local log = require "log"
local capabilities = require "st.capabilities"
local ZigbeeDriver = require "st.zigbee"
local defaults = require "st.zigbee.defaults"


local zigbee_konke_button_driver_template = {
  supported_capabilities = {
    capabilities.button,
    capabilities.battery,
    capabilities.refresh
  },
  sub_drivers = {
    require("konke")
  }
}

defaults.register_for_default_handlers(zigbee_konke_button_driver_template, zigbee_konke_button_driver_template.supported_capabilities)
local zigbee_driver = ZigbeeDriver("zigbee-konke-button", zigbee_konke_button_driver_template)
zigbee_driver:run()