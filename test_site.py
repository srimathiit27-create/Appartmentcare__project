from pathlib import Path
from playwright.sync_api import sync_playwright
html=Path(__file__).with_name('index.html').read_text()
with sync_playwright() as p:
 browser=p.chromium.launch(headless=True,executable_path='/usr/bin/chromium',args=['--no-sandbox'])
 page=browser.new_page(viewport={'width':1365,'height':900}); errors=[]; page.on('pageerror',lambda e:errors.append(str(e)))
 # Sandboxed runner blocks file/loopback origins; provide a localStorage-compatible test shim.
 shim="<script>(()=>{const store={};Object.defineProperty(window,'localStorage',{configurable:true,value:{getItem:k=>store[k]??null,setItem:(k,v)=>store[k]=String(v)}})})()</script>"
 page.set_content(html.replace('<head>','<head>'+shim)); page.wait_for_selector('#dueTotal'); assert page.locator('#buildingGrid .block').count()==4
 assert page.locator('#complaintRows tr').count()>0
 page.get_by_role('button',name='Resident portal').click(); page.locator('#residentApt').select_option(label=page.locator('#residentApt option').nth(0).inner_text()); page.locator('#loadDues').click(); assert 'outstanding' in page.locator('#residentDues').inner_text()
 page.get_by_role('button',name='Building view').click(); page.locator('[data-apt]').first.click(); assert 'Apartment' in page.locator('#aptDetail').inner_text()
 page.get_by_role('button',name='Admin dashboard').click(); page.locator('#theme').click(); page.screenshot(path=str(Path(__file__).resolve().parents[1]/'screenshots'/'website-dashboard.png'),full_page=True)
 assert not errors,errors
 print('WEBSITE TEST PASS: loads; 4 blocks; complaint queue; resident dues; apartment selection; theme toggle; no JS errors (localStorage shim)')
 browser.close()
