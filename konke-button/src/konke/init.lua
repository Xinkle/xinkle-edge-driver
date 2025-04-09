-- Zigbee Konke Button
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
local zcl_clusters = require "st.zigbee.zcl.clusters"

-- Konke 버튼 모델 정의
local KONKE_BUTTON_FINGERPRINTS = {
  { mfr = "Konke", model = "3AFE280100510001" }
}

-- 엔드포인트 오프셋 계산 함수
local function get_ep_offset(device)
  return device.fingerprinted_endpoint_id - 1
end

-- 버튼 핸들러
local button_handler = function(driver, device, zb_rx)
  log.info("<<---- Konke ---->> button_handler")
  
  -- components의 key들을 확인
  log.info("<<---- Konke ---->> Available components:")
  for key, _ in pairs(device.profile.components) do
    log.info(string.format("<<---- Konke ---->> Component key: '%s'", key))
  end
  
  -- 엔드포인트 기반으로 component_id 생성
  -- local component_id = string.format("button%d", zb_rx.address_header.src_endpoint.value)
  -- log.info("<<---- Konke ---->>", zb_rx.address_header.src_endpoint.value)
  
  -- 조건 없이 항상 pushed 이벤트 발생
  local ev = capabilities.button.button.pushed()
  if ev then
    ev.state_change = true
    device.profile.components["button1"]:emit_event(ev)
    log.info("<<---- Konke ---->> Button pushed event emitted")
  end
end


-- 디바이스 추가시 초기화
local device_added = function(driver, device)
  log.info("<<---- Konke ---->> device_added")
  
  for key, value in pairs(device.profile.components) do
    log.info("<<---- Konke ---->> device_added - component : ", key)
    device.profile.components[key]:emit_event(capabilities.button.supportedButtonValues({ "pushed" }))
    device.profile.components[key]:emit_event(capabilities.button.button.pushed())
  end
end

-- 디바이스 설정
local device_doconfigure = function(self, device)
  log.info("<<---- Konke ---->> configure_device")
  device:configure()
  
  -- 배터리 리포팅 설정
  device:send(zcl_clusters.PowerConfiguration.attributes.BatteryPercentageRemaining:configure_reporting(device, 30, 21600, 1))
end

-- Konke 디바이스 체크 함수
local is_konke_button = function(opts, driver, device)
  for _, fingerprint in ipairs(KONKE_BUTTON_FINGERPRINTS) do
    log.info("<<---- Konke ---->> is_konke_button checking device(6):", device:get_manufacturer(), device:get_model())
    
    if device:get_manufacturer() == fingerprint.mfr and device:get_model() == fingerprint.model then
      log.info("<<---- Konke ---->> is_konke_button: true")
      return true
    end
  end
  
  log.info("<<---- Konke ---->> is_konke_button: false")
  return false
end

-- 서브 드라이버 정의
local konke_button = {
  NAME = "Konke Button",
  zigbee_handlers = {
    attr = {
      [zcl_clusters.OnOff.ID] = {
        [0x0000] = button_handler  -- Report Attribute 메시지의 AttributeId 0x0000에 등록
      },
      [0x0001] = {  -- PowerConfiguration 클러스터 ID
        [0x0021] = function(driver, device, value, zb_rx)  -- BatteryPercentageRemaining 속성 ID
          local battery_level = math.floor(value.value / 2)
          device:emit_event(capabilities.battery.battery(battery_level))
        end
      }
    }
  },
  lifecycle_handlers = {
    added = device_added,
    doConfigure = device_doconfigure,
  },
  can_handle = is_konke_button
}

return konke_button 