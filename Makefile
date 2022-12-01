#
# Copyright (C) 2018 Jianhui Zhao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rtty

PKG_VERSION:=8.0.1-2
SOURCE_VERSION:=8.0.1-1
PKG_RELEASE:=hi
PKG_HASH:=6a3044b9346caa17a5c4b2b7aa055367963fbddddd1c1c47cb6f8a1c223d4117

PKG_SOURCE:=$(PKG_NAME)-$(SOURCE_VERSION).tar.gz
PKG_SOURCE_URL=https://github.com/innet8/rtty/releases/download/v$(SOURCE_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(SOURCE_VERSION)
CMAKE_INSTALL:=1

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Jianhui Zhao <zhaojh329@gmail.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/rtty/Default
  TITLE:=Access your terminals from anywhere via the web
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Terminal
  URL:=https://github.com/innet8/rtty
  DEPENDS:=+libev $(2)
  VARIANT:=$(1)
  PROVIDES:=rtty
endef

Package/rtty-openssl=$(call Package/rtty/Default,openssl,+PACKAGE_rtty-openssl:libopenssl)
Package/rtty-mbedtls=$(call Package/rtty/Default,mbedtls,+PACKAGE_rtty-mbedtls:libmbedtls +PACKAGE_rtty-mbedtls:zlib)
Package/rtty-nossl=$(call Package/rtty/Default,nossl)

define Package/rtty-openssl/conffiles
/etc/config/rtty
endef

Package/rtty-mbedtls/conffiles = $(Package/rtty-openssl/conffiles)
Package/rtty-nossl/conffiles = $(Package/rtty-openssl/conffiles)

ifeq ($(BUILD_VARIANT),openssl)
  CMAKE_OPTIONS += -DUSE_OPENSSL=ON
else ifeq ($(BUILD_VARIANT),mbedtls)
  CMAKE_OPTIONS += -DUSE_MBEDTLS=ON
else
  CMAKE_OPTIONS += -DSSL_SUPPORT=OFF
endif

define Package/rtty-$(BUILD_VARIANT)/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/rtty $(1)/usr/sbin
	$(INSTALL_BIN) ./files/rtty.init $(1)/etc/init.d/rtty
	$(INSTALL_CONF) ./files/rtty.config $(1)/etc/config/rtty
	$(INSTALL_BIN) ./files/99-rtty $(1)/etc/uci-defaults
endef

$(eval $(call BuildPackage,rtty-openssl))
$(eval $(call BuildPackage,rtty-mbedtls))
$(eval $(call BuildPackage,rtty-nossl))
