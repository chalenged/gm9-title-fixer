y_title_fixer.firm: title-fixer.lua
	cp title-fixer.lua GodMode9/data/autorun.lua
	$(MAKE) -C GodMode9 -B SCRIPT_RUNNER=1
	cp GodMode9/output/GodMode9.firm $@

.PHONY: clean
clean:
	rm -f *.firm
	rm -f GodMode9/data/autorun.lua
	$(MAKE) -C GodMode9 clean
