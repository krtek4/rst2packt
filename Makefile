ISBN=B05255

BUILD=.builds
OUTPUTS=$(BUILD)/outputs
OUT=dist
CONFIG_DIR=rst2packt

RST=$(sort $(wildcard *.rst))

all: html

FULL_HTML=$(OUT)/document.html
html: $(FULL_HTML)

STYLES=$(CONFIG_DIR)/odt.ini
TEMPLATE=$(CONFIG_DIR)/styles.odt
ODT=$(addprefix $(OUT)/$(ISBN)_, $(RST:.rst=.odt))
odt: $(ODT)

ZIP=$(addprefix $(OUT)/$(ISBN)_, $(RST:.rst=.zip))
zip: lint $(ZIP)

pdf: $(FULL_RST)
	@cd $(OUT); pdftk $(ISBN)*.pdf cat output document.pdf
	@echo "document.pdf created."

PHP=$(wildcard src/*.php)
LINT=$(addprefix $(OUTPUTS)/, $(addsuffix .lint, $(notdir $(PHP))))
PHP5=$(wildcard src/*.php5)
LINT5=$(addprefix $(OUTPUTS)/, $(addsuffix .lint, $(notdir $(PHP5))))
lint: $(OUTPUTS) $(LINT) $(LINT5)

PHPOUT=$(addprefix $(OUTPUTS)/, $(notdir $(PHP)))
PHPOUT5=$(addprefix $(OUTPUTS)/, $(notdir $(PHP5)))
output: $(OUTPUTS) $(PHPOUT) $(PHPOUT5)
	@git checkout -- src/01-strict-types.php src/02-lazy-evaluation.php src/03-error-handlers.php

clean: clean-build clean-dist

clean-build:
	@rm -Rf $(BUILD)/*

clean-dist:
	@rm -Rf $(OUT)/*

# Helpers
$(BUILD)/src: src/*
	@rm -rf $@
	@cp -rf src $@

$(BUILD)/assets: assets/*
	@rm -rf $@
	@cp -rf assets $@

$(OUTPUTS):
	@mkdir -p $@

# HTML related rules
FULL_RST=$(BUILD)/document.rst
FULL_HTML_TMP=$(BUILD)/document.html
CSS=$(CONFIG_DIR)/packt.css

$(FULL_RST): $(RST)
	@cat $(CONFIG_DIR)/title-page.rst > $@
	@for i in *.rst; do echo >> $@; cat $$i >> $@; done

$(FULL_HTML_TMP): $(FULL_RST) $(BUILD)/src $(BUILD)/assets $(CSS)
	@rst2html -t --halt none --stylesheet "/usr/share/docutils/writers/html4css1/html4css1.css","$(CSS)" $(FULL_RST) > $(FULL_HTML_TMP)

$(FULL_HTML): $(FULL_HTML_TMP)
	@cp -f $< $@
	@echo "$@ created."

# ODT related rules
$(BUILD)/%.rst: %.rst
	@cat $(CONFIG_DIR)/title-page.rst > $@
	@echo >> $@
	@cat $< >> $@

$(BUILD)/$(ISBN)_%.odt: $(BUILD)/%.rst $(BUILD)/src $(BUILD)/assets $(STYLES) $(TEMPLATE)
	@rst2odt -r3 --odf-config-file=$(STYLES) --stylesheet=$(TEMPLATE) --no-sections --add-syntax-highlighting --smart-quotes=yes $< $@ 2>&1 | tee $(basename $<).log
	@unzip -qq -p $@ content.xml > content.xml
	@# remove first two elements (title and author)
	@xmlstarlet ed -P -S --delete "office:document-content/office:body/office:text/text:p[1]" content.xml > content2.xml
	@xmlstarlet ed -P -S --delete "office:document-content/office:body/office:text/text:p[1]" content2.xml > content3.xml
	@xmlstarlet ed -P -S --delete "office:document-content/office:body/office:text/text:table-of-content" content3.xml > content4.xml
	@mv -f content4.xml content.xml
	@zip --quiet $@ content.xml
	@rm -f content*.xml

$(OUT)/$(ISBN)_%.odt: $(BUILD)/$(ISBN)_%.odt
	@mv -f $< $@
	@unoconv -l &
	@unoconv -f pdf $@
	@pkill .*unoconv.* ; true
	@echo "$@ written."
	@pdftk $(@:.odt=.pdf) dump_data | grep NumberOfPages

# ZIP related rules
$(OUT)/$(ISBN)_%.zip: $(OUT)/$(ISBN)_%.odt
	@$(eval NUMBER := $(firstword $(subst -, ,$(subst $(ISBN)_,,$(notdir $@)))))
	@rm -rf $(basename $@)
	@rm -f $@
	@mkdir -p $(basename $@)
	@cp $< $(basename $@)
	@find $(BUILD)/assets -not -name '.git' -name $(ISBN)_$(NUMBER)\* -exec cp {} $(basename $@) \;
	@find $(BUILD)/src -maxdepth 1 -name $(NUMBER)\* -exec cp {} $(basename $@) \;
	@# find $(basename $@)/ -name \*.php.errors | sed -e "p;s/php.errors$$/php/" | xargs -n2 mv -f
	@# find $(basename $@)/ -name \*.php71 | sed -e "p;s/php71$$/php/" | xargs -n2 mv -f
	@cd $(OUT); zip --quiet $(notdir $@) -r $(basename $(notdir $@))
	@rm -rf $(basename $@)
	@echo "$@ created."

# Linting
$(OUTPUTS)/%.php.lint: src/%.php
	@echo "$< : \033[0;31m"
	@php7.0 -l $< | tee > $@
	@echo "\033[0m"

$(OUTPUTS)/%.php5.lint: src/%.php5
	@echo "$< \n\033[0;34m\tPHP7 :\033[0;31m"
	@php7.0 -l $< | tee > $@
	@echo "\033[0;34m\tPHP5 :\033[0;31m"
	@php5 -l $< | tee >> $@
	@echo "\033[0m"

# PHP outputs
$(OUTPUTS)/%.php: src/%.php $(CONFIG_DIR)/run.sh $(CONFIG_DIR)/boris.php
	$(CONFIG_DIR)/run.sh $< $@

$(OUTPUTS)/%.php5: src/%.php5 $(CONFIG_DIR)/run.sh $(CONFIG_DIR)/boris.php
	$(CONFIG_DIR)/run.sh $< $@
