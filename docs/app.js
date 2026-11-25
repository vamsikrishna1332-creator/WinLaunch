
/* LaunchDesk Web Demo · local-only browser implementation.
 * No account authentication, server tracking, OS app launching, or secret storage.
 */
(function () {
  'use strict';
  const KEY = 'launchdesk-web-demo-v1';
  const $ = (selector) => document.querySelector(selector);
  const esc = (value) => String(value == null ? '' : value).replace(/[&<>"']/g, (c) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  }[c]));
  const uid = () => crypto && typeof crypto.randomUUID === 'function'
    ? crypto.randomUUID() : String(Date.now()) + Math.random().toString(36).slice(2);
  const icons = {
    dashboard: '<path d="M3 11 12 3l9 8v10H3z"/><path d="M9 21v-7h6v7"/>',
    calendar: '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4m10-4v4M3 10h18"/>',
    check: '<path d="m4 12 5 5L20 6"/>',
    notes: '<path d="m3 21 5-.9L20 8l-4-4L4 16z"/><path d="m14 6 4 4"/>',
    apps: '<rect x="3" y="3" width="8" height="8"/><rect x="13" y="3" width="8" height="8"/><rect x="3" y="13" width="8" height="8"/><rect x="13" y="13" width="8" height="8"/>',
    timer: '<circle cx="12" cy="13" r="9"/><path d="M12 13V7m0 6 4 3M10 2h4"/>',
    star: '<path d="m12 2 3 7 7 .6-5.2 4.7 1.6 7L12 17.5 5.6 21l1.6-7L2 9.6 9 9z"/>',
    journal: '<path d="M6 3h10l4 4v14H6z"/><path d="M16 3v5h4M9 12h8m-8 4h8"/>',
    settings: '<circle cx="12" cy="12" r="3"/><path d="M12 2v3m0 14v3M2 12h3m14 0h3M5 5l2 2m10 10 2 2M19 5l-2 2M7 17l-2 2"/>',
    chat: '<path d="M3 5h18v12H9l-6 4z"/>',
    activity: '<path d="M3 12h4l3-7 4 14 3-7h4"/>',
    clock: '<circle cx="12" cy="12" r="9"/><path d="M12 6v6l4 2"/>',
    battery: '<rect x="3" y="6" width="17" height="12" rx="2"/><path d="M22 10v4"/>',
    link: '<path d="M10 13a5 5 0 0 0 7 .5l3-3a5 5 0 0 0-7-7l-2 2M14 11a5 5 0 0 0-7-.5l-3 3a5 5 0 0 0 7 7l2-2"/>'
  };
  const ico = (name) => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.65" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' + (icons[name] || icons.apps) + '</svg>';
  const MENU = [
    ['dashboard','Dashboard','dashboard'],['schedule','Schedule','calendar'],
    ['tasks','Tasks','check'],['notes','Notes','notes'],['apps','Apps','apps'],
    ['focus','Focus Timer','timer'],['habits','Habits','star'],
    ['activity','Activity','activity'],['journal','Journal','journal'],
    ['settings','Settings','settings'],['chatgpt','ChatGPT','chat'],
    ['widgets','Widgets','apps']
  ];
  function defaultData() {
    return {
      version: 1,
      settings: {
        theme: 'dark', accent: '#8c79fc', compact: false, showSeconds: true,
        hour24: false, reducedMotion: false, focusMinutes: 25, breakMinutes: 5,
        showQuickApps: true, showBattery: true, showTasks: true, showNotes: true,
        showSchedule: true, showFocus: true, showActivity: true,
        notifyTimer: true
      },
      schedules: [], tasks: [], notes: [], habits: [], journal: [],
      apps: [
        {id:'app-github',name:'GitHub',url:'https://github.com/',symbol:'⌘',category:'Development'},
        {id:'app-vscode',name:'VS Code',url:'https://code.visualstudio.com/',symbol:'⌨',category:'Development'},
        {id:'app-chatgpt',name:'ChatGPT',url:'https://chatgpt.com/',symbol:'✦',category:'Productivity'}
      ],
      habitChecks: {}, events: [],
      focus: { mode: 'focus', remaining: 1500, running: false, endAt: null, completed: 0 }
    };
  }
  const ARRAY_FIELDS = ['schedules','tasks','notes','habits','journal','apps','events'];
  function validateImport(raw) {
    if (!raw || typeof raw !== 'object' || Array.isArray(raw)) throw Error('Invalid backup format');
    const fresh = defaultData();
    const next = { ...fresh, ...raw, settings: { ...fresh.settings, ...(raw.settings || {}) } };
    for (const field of ARRAY_FIELDS) {
      if (!Array.isArray(next[field]) || next[field].length > 1000) throw Error('Invalid ' + field + ' entries');
      next[field] = next[field].filter(x => x && typeof x === 'object' && !Array.isArray(x));
    }
    if (!next.habitChecks || typeof next.habitChecks !== 'object' || Array.isArray(next.habitChecks)) next.habitChecks = {};
    if (!next.focus || typeof next.focus !== 'object') next.focus = fresh.focus;
    next.focus = { ...fresh.focus, ...next.focus, running: false, endAt: null };
    next.settings.accent = validColor(next.settings.accent) ? next.settings.accent : fresh.settings.accent;
    next.settings.theme = next.settings.theme === 'light' ? 'light' : 'dark';
    next.version = 1;
    return next;
  }
  function validColor(x) { return typeof x === 'string' && /^#[a-f\d]{6}$/i.test(x); }
  function load() {
    try {
      const value = localStorage.getItem(KEY);
      return value ? validateImport(JSON.parse(value)) : defaultData();
    } catch (e) {
      console.warn('LaunchDesk demo storage unavailable or corrupt:', e);
      return defaultData();
    }
  }
  let data = load();
  let page = 'dashboard';
  let search = '';
  let battery = null;
  const now = () => new Date();
  const dateKey = (d = now()) => d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-' + String(d.getDate()).padStart(2,'0');
  const duration = (s) => String(Math.floor(Math.max(0,s) / 60)).padStart(2,'0') + ':' + String(Math.max(0,s)%60).padStart(2,'0');
  function store() { try { localStorage.setItem(KEY, JSON.stringify(data)); } catch { toast('Browser storage is full or disabled. Changes may not persist.', true); } }
  function logEvent(title, type = 'general') {
    data.events.unshift({id:uid(),title,at:new Date().toISOString(),type});
    data.events = data.events.slice(0,100);
  }
  function toast(message, error=false) {
    const el=document.createElement('div');
    el.className='toast'+(error?' error':'');
    el.textContent=message;
    $('#toasts').appendChild(el);
    setTimeout(()=>el.remove(),3200);
  }
  function time(date, short=false) {
    return new Date(date).toLocaleTimeString(undefined,{
      hour:'2-digit',minute:'2-digit',second:!short&&data.settings.showSeconds?'2-digit':undefined,
      hour12: !data.settings.hour24
    });
  }
  function humanDate(d) { return new Date(d).toLocaleDateString(undefined,{weekday:'long',day:'numeric',month:'short',year:'numeric'}); }
  function prettyDate(d) { return new Date(d+'T12:00:00').toLocaleDateString(undefined,{month:'short',day:'numeric',year:'numeric'}); }
  function scheduleOn(s,d=now()){
    if(!s || !s.date || !s.start || !s.end) return false;
    const k=dateKey(d), repeat=s.repeat||'once';
    if(k<s.date) return false;
    if(repeat==='once') return k===s.date;
    if(repeat==='daily') return true;
    if(repeat==='weekdays') return d.getDay()>0&&d.getDay()<6;
    if(repeat==='weekends') return d.getDay()===0||d.getDay()===6;
    if(repeat==='weekly') return new Date(s.date+'T12:00:00').getDay()===d.getDay();
    return false;
  }
  function scheduledBounds(s, d=now()){
    if(!scheduleOn(s,d))return null;
    const day=dateKey(d);
    const start=new Date(day+'T'+s.start+':00');
    const end=new Date(day+'T'+s.end+':00');
    if(end<=start) end.setDate(end.getDate()+1);
    return {start,end};
  }
  function todaySchedules(){
    return data.schedules.filter(s=>scheduleOn(s)).sort((a,b)=>a.start.localeCompare(b.start));
  }
  function runningSchedule(){
    return todaySchedules().find(s=>{const b=scheduledBounds(s);return b&&now()>=b.start&&now()<b.end;})||null;
  }
  function nextSchedule(){
    const candidates=[];
    for(let i=0;i<9;i++){
      const d=new Date();d.setDate(d.getDate()+i);
      for(const s of data.schedules){
        const b=scheduledBounds(s,d);
        if(b&&b.start>now()) candidates.push({s,start:b.start});
      }
    }
    candidates.sort((a,b)=>a.start-b.start);
    return candidates[0]||null;
  }
  function progressFor(s) {
    const b=s&&scheduledBounds(s);
    if(!b)return 0;
    return Math.max(0,Math.min(100,Math.round((now()-b.start)/(b.end-b.start)*100)));
  }
  function setPage(id) {
    if(!MENU.some(x=>x[0]===id))return;
    page=id;search='';render();
    const main=$('#content');main.scrollTop=0;
    window.scrollTo({top:0,behavior:'instant'});
  }
  function applySettings(){
    document.documentElement.dataset.theme=data.settings.theme;
    document.documentElement.dataset.compact=String(data.settings.compact);
    document.documentElement.dataset.motion=data.settings.reducedMotion?'reduced':'full';
    document.documentElement.style.setProperty('--accent',data.settings.accent);
    document.documentElement.style.setProperty('--accent-soft',data.settings.accent+'33');
  }
  function renderNav(){
    $('#nav').innerHTML=MENU.map((n,i)=>
      (i===10?'<div class="nav-section">INTEGRATIONS</div>':'')+
      '<button class="nav-link'+(page===n[0]?' active':'')+'" data-page="'+n[0]+'" '+(page===n[0]?'aria-current="page"':'')+' title="'+esc(n[1])+'">'+ico(n[2])+'<span>'+esc(n[1])+'</span></button>'
    ).join('');
  }
  function head(title,sub,buttons=''){
    return '<div class="page-header"><div><h1>'+esc(title)+'</h1><div class="subline">'+esc(sub)+'</div></div><div class="page-actions">'+buttons+'</div></div>';
  }
  function card(content,extra=''){return '<section class="card '+extra+'">'+content+'</section>';}
  function title(text){return '<h2 class="card-title">'+esc(text)+'</h2>';}
  function btn(text,act,id='',variant='secondary'){return '<button class="btn '+variant+' small" data-action="'+esc(act)+'" data-id="'+esc(id)+'">'+esc(text)+'</button>';}
  function badge(text,cls=''){return '<span class="pill '+cls+'">'+esc(text)+'</span>';}
  function ring(pct,main,sub,color='var(--accent)'){
    return '<div class="ring" style="--pct:'+Math.min(100,Math.max(0,pct))+'%;--ring-color:'+color+'"><div class="ring-inner"><strong>'+esc(main)+'</strong><small>'+esc(sub)+'</small></div></div>';
  }
  function miniSchedule(s){
    return '<div class="date-mini"><span class="date-dot" style="background:'+esc(validColor(s.color)?s.color:data.settings.accent)+'"></span><div class="line-main"><div class="line-title">'+esc(s.title)+'</div><div class="time">'+esc(s.start)+' – '+esc(s.end)+'</div></div>'+ (s===runningSchedule()?badge('RUNNING','ok'):'')+'</div>';
  }
  function miniNote(n){return '<div class="date-mini"><span class="date-dot"></span><span class="line-main tiny">'+esc(n.title)+'</span></div>';}
  function focusPercent() {
    const total=(data.focus.mode==='focus'?data.settings.focusMinutes:data.settings.breakMinutes)*60;
    return total ? (1-data.focus.remaining/total)*100 : 0;
  }
  function renderDashboard(){
    const active=runningSchedule();
    const next=nextSchedule();
    const completed=data.tasks.filter(t=>t.done).length;
    const taskTotal=data.tasks.length;
    const prog=progressFor(active);
    const activeText=active?esc(active.title):'No active task';
    const upcomingText=next?esc(next.s.title):'Nothing upcoming';
    const stats=[
      [taskTotal,'Total Tasks',''],[completed,'Completed','green'],
      [taskTotal-completed,'In Progress','yellow'],[taskTotal-completed,'Pending','blue']
    ];
    const mainRunning=card(
      '<div class="status-green">● NOW RUNNING</div><div class="active-task"><div><h2>'+activeText+'</h2><div class="muted tiny">'+(active?'Progress through your scheduled time':'Add a schedule to get started')+'</div><div class="status-green" style="margin-top:17px">'+(active?'IN PROGRESS':'READY')+'</div></div>'+ring(prog,prog+'%','Complete','#2ad389')+'</div>'+
      '<div class="progress" style="width:40%"><span style="width:'+prog+'%"></span></div>'+
      '<div class="next-line"><span>NEXT</span><span>'+(next?esc(next.s.start):'--')+'</span></div><div class="muted tiny">'+upcomingText+'</div>'
    );
    const mainSchedule=card(
      '<div class="card-head">'+title("TODAY'S SCHEDULE")+'<button class="link-btn" data-page="schedule">View all</button></div>'+
      (todaySchedules().length?todaySchedules().slice(0,5).map(miniSchedule).join(''):'<div class="muted">No schedules yet</div>')
    );
    const focusCard=card(title('FOCUS TIMER')+'<div class="focus-line">'+ring(focusPercent(),duration(data.focus.remaining),data.focus.mode==='focus'?'Focus':'Break')+
      '<div class="focus-description"><b>Ready to focus?</b><p>Eliminate distractions and get things done.</p>'+btn(data.focus.running?'Pause Focus':'Start Focus','focus-toggle','','')+'</div></div>');
    const taskCard=card(title('TASKS OVERVIEW')+'<div class="stats-two">'+stats.map(s=>'<div class="stat"><span class="stat-circle '+s[2]+'">'+s[0]+'</span><span>'+s[1]+'</span></div>').join('')+'</div>');
    const noteCard=card('<div class="card-head">'+title('QUICK NOTES')+'<button class="icon-button" data-action="new-note" aria-label="Add note">＋</button></div>'+
      (data.notes.length?data.notes.slice(0,3).map(miniNote).join(''):'<div class="muted tiny">Add your first note</div>'));
    const appsCard=card('<div class="card-head">'+title('QUICK LAUNCH')+'<button class="link-btn" data-page="apps">+ Add</button></div><div class="quickapps">'+
      (data.apps.length?data.apps.slice(0,7).map(a=>'<button class="quickapp" data-action="open-app" data-id="'+esc(a.id)+'"><span class="shortcut-icon">'+esc(a.symbol||'▦')+'</span><span>'+esc(a.name)+'</span></button>').join(''):'<span class="muted tiny">Add links from Apps</span>')+'</div>'
    );
    const batteryCard=card('<div class="battery">'+ico('battery')+'<div><span>Battery</span><strong id="battery-percent">'+(battery?battery.level+'%':'N/A')+'</strong><span id="battery-label">'+(battery?battery.label:'Browser may restrict battery status')+'</span></div></div>');
    let content='<div class="greeting-row"><div><div class="welcome-sub">Welcome back,</div><h1>Demo User 👋</h1><div class="subline">Stay focused. Stay consistent. Success is on the way.</div></div>'+
      '<div class="clock-card">'+ico('clock')+'<div><div id="live-time" class="clock-time">'+esc(time(now()))+'</div><div id="live-date" class="clock-date">'+esc(humanDate(now()))+'</div></div></div></div>';
    content+='<div class="grid-main">'+(data.settings.showSchedule?mainRunning+mainSchedule:mainRunning)+'</div>';
    const middle=[data.settings.showFocus?focusCard:'',data.settings.showTasks?taskCard:'',data.settings.showNotes?noteCard:''].filter(Boolean);
    if(middle.length)content+='<div class="grid-mid">'+middle.join('')+'</div>';
    const bottom=[data.settings.showQuickApps?appsCard:'',data.settings.showBattery?batteryCard:''].filter(Boolean);
    if(bottom.length)content+='<div class="grid-bottom">'+bottom.join('')+'</div>';
    return content;
  }
  function renderTasks(){
    const todo=data.tasks.filter(t=>!t.done),finished=data.tasks.filter(t=>t.done);
    function row(t){
      return '<div class="line-item"><input class="checkbox" type="checkbox" aria-label="Complete '+esc(t.title)+'" data-check-task="'+esc(t.id)+'" '+(t.done?'checked':'')+'>'+
        '<div class="line-main"><div class="line-title '+(t.done?'struck':'')+'">'+esc(t.title)+'</div>'+
        '<div class="line-sub">'+esc(t.priority||'Normal')+(t.due?' · Due '+prettyDate(t.due):'')+'</div></div>'+
        '<div class="line-actions">'+btn('Edit','edit-task',t.id)+btn('Delete','delete-task',t.id)+'</div></div>';
    }
    return head('Tasks','Keep track of everything you need to do',btn('+ Add Task','new-task','','accent'))+
      card(title('TO-DO LIST')+(todo.length?todo.map(row).join(''):'<div class="empty">All caught up! Add a new task to begin.</div>'))+
      '<div style="height:14px"></div>'+
      card(title('COMPLETED')+(finished.length?finished.map(row).join(''):'<div class="empty">Completed tasks will appear here.</div>'));
  }
  function renderSchedule(){
    const today=todaySchedules();
    const byHour=Array.from({length:16},(_,i)=>i+7).map(hour=>{
      const matches=today.filter(s=>Number(s.start.slice(0,2))===hour);
      const hr=new Date();hr.setHours(hour,0,0,0);
      return '<div class="day-row"><div class="day-hour">'+esc(time(hr,true))+'</div><div class="day-events">'+matches.map(s=>
        '<button class="event-chip" style="border-left-color:'+esc(validColor(s.color)?s.color:data.settings.accent)+'" data-action="edit-schedule" data-id="'+esc(s.id)+'">'+esc(s.title)+' · '+esc(s.start)+'</button>'
      ).join('')+'</div></div>';
    }).join('');
    return head('Schedule','Your day at a glance',btn('+ Add Schedule','new-schedule','','accent'))+
      '<div class="board two">'+card('<div class="card-head">'+title('DAY VIEW · '+humanDate(now()).toUpperCase())+badge(today.length+' events')+'</div>'+byHour)+
      card(title('ALL SCHEDULES')+(data.schedules.length?data.schedules.map(s=>
        '<div class="line-item"><div class="date-dot" style="background:'+esc(validColor(s.color)?s.color:data.settings.accent)+'"></div><div class="line-main"><div class="line-title">'+esc(s.title)+'</div><div class="line-sub">'+prettyDate(s.date)+' · '+esc(s.start)+'–'+esc(s.end)+' · '+esc(s.repeat||'once')+'</div></div>'+btn('Edit','edit-schedule',s.id)+btn('Delete','delete-schedule',s.id)+'</div>'
      ).join(''):'<div class="empty">Nothing on your schedule yet.</div>'))+'</div>';
  }
  function renderNotes(journal=false){
    const entries=journal?data.journal:data.notes;
    const word=journal?'Journal':'Notes', singular=journal?'Entry':'Note';
    return head(word,journal?'Capture your days and ideas':'Organize ideas and thoughts',btn('+ New '+singular,journal?'new-journal':'new-note','','accent'))+
      (entries.length?'<div class="note-grid">'+entries.slice().sort((a,b)=>(b.updated||'').localeCompare(a.updated||'')).map(n=>
        card('<div class="card-head"><b>'+esc(n.title)+'</b>'+ (journal?badge(n.mood||'Reflective'):'')+'</div><div class="note-body">'+esc(n.body).replace(/\n/g,'<br>')+'</div><footer><span>'+esc(new Date(n.updated).toLocaleDateString())+'</span><span>'+btn('Edit',journal?'edit-journal':'edit-note',n.id)+ ' '+btn('Delete',journal?'delete-journal':'delete-note',n.id)+'</span></footer>','note')
      ).join('')+'</div>':card('<div class="empty">No '+word.toLowerCase()+' yet. Your new entries stay in this browser.</div>'));
  }
  function safeUrl(value){
    try {const url=new URL(value);return ['https:','http:'].includes(url.protocol)?url.href:null;} catch{return null;}
  }
  function renderApps(){
    const filtered=data.apps.filter(a=>(a.name+' '+(a.category||'')).toLowerCase().includes(search.toLowerCase()));
    return head('Apps','Save website shortcuts for quick access',btn('+ Add Shortcut','new-app','','accent'))+
      '<div class="demo-banner"><b>Browser demo</b> Shortcuts open websites in a new tab. Browsers cannot open local Windows .exe files.</div>'+
      '<div class="toolbar"><input id="search-apps" class="search" type="search" placeholder="Search shortcuts…" value="'+esc(search)+'" aria-label="Search shortcuts">'+badge(data.apps.length+' shortcuts')+'</div>'+
      (filtered.length?'<div class="app-grid">'+filtered.map(a=>
        card('<div class="shortcut-icon">'+esc(a.symbol||'▦')+'</div><b>'+esc(a.name)+'</b><small>'+esc(a.category||'Website')+'</small><div class="actions">'+btn('Open','open-app',a.id,'')+btn('Edit','edit-app',a.id)+btn('×','delete-app',a.id)+'</div>','app-tile')
      ).join('')+'</div>':card('<div class="empty">No matching shortcuts.</div>'));
  }
  function renderFocus(){
    const f=data.focus;
    return head('Focus Timer','Stay in the zone')+card(
      title(f.mode==='focus'?'POMODORO · FOCUS SESSION':'SHORT BREAK')+
      '<div id="big-ring">'+ring(focusPercent(),duration(f.remaining),f.mode==='focus'?'Focus':'Break')+'</div>'+
      '<div class="focus-actions">'+btn(f.running?'Pause Timer':'Start Timer','focus-toggle','','accent')+btn('Reset','focus-reset')+'</div>'+
      '<div class="focus-modes"><button class="btn secondary small" aria-pressed="'+(f.mode==='focus')+'" data-action="focus-mode" data-id="focus">Focus ('+data.settings.focusMinutes+' min)</button>'+
      '<button class="btn secondary small" aria-pressed="'+(f.mode==='break')+'" data-action="focus-mode" data-id="break">Break ('+data.settings.breakMinutes+' min)</button></div>'+
      '<p class="muted">Completed focus sessions: '+f.completed+'</p>'
    ,'focus-panel');
  }
  function renderHabits(){
    const days=Array.from({length:7},(_,i)=>{const d=new Date();d.setDate(d.getDate()-6+i);return d;});
    return head('Habits','Build consistency, one day at a time',btn('+ Add Habit','new-habit','','accent'))+
      card(title('WEEKLY HABIT TRACKER')+
      '<div class="habit-week header"><span>Habit</span>'+days.map(d=>'<span>'+esc(d.toLocaleDateString(undefined,{weekday:'short'}))+'</span>').join('')+'<span></span></div>'+
      (data.habits.length?data.habits.map(h=>
        '<div class="habit-week"><b>'+esc(h.title)+'</b>'+days.map(d=>{
          const k=dateKey(d);
          return '<input class="habit-check" type="checkbox" aria-label="'+esc(h.title)+' on '+esc(k)+'" data-habit="'+esc(h.id)+'" data-day="'+k+'" '+(data.habitChecks[k]&&data.habitChecks[k].includes(h.id)?'checked':'')+'>';
        }).join('')+btn('Delete','delete-habit',h.id)+'</div>'
      ).join(''):'<div class="empty">Add a habit to get started.</div>'));
  }
  function renderActivity(){
    const activities=data.events.filter(e=>data.settings.showActivity);
    const counts={tasks:data.tasks.length,notes:data.notes.length,journal:data.journal.length,apps:data.apps.length,focus:data.focus.completed};
    return head('Activity','Your local LaunchDesk demo history',btn('Clear History','clear-activity'))+
      '<div class="board three">'+card('<div class="stat">'+title('TASKS')+'<strong style="margin-left:auto;font-size:26px">'+counts.tasks+'</strong></div>')+
      card('<div class="stat">'+title('NOTES & JOURNAL')+'<strong style="margin-left:auto;font-size:26px">'+(counts.notes+counts.journal)+'</strong></div>')+
      card('<div class="stat">'+title('FOCUS SESSIONS')+'<strong style="margin-left:auto;font-size:26px">'+counts.focus+'</strong></div>')+
      card(title('RECENT ACTIVITY')+(activities.length?activities.slice(0,30).map(e=>
        '<div class="line-item"><span class="date-dot"></span><div class="line-main"><div>'+esc(e.title)+'</div><div class="line-sub">'+esc(new Date(e.at).toLocaleString())+'</div></div></div>'
      ).join(''):'<div class="empty">Activity will appear as you use the demo.</div>'),'wide')+'</div>';
  }
  function renderChatGPT(){
    return head('ChatGPT','Official ChatGPT account sign-in')+
      card('<div class="stack" style="max-width:600px"><div style="font-size:24px;font-weight:750">ChatGPT</div><div class="muted">Open the official ChatGPT website and sign in using your own account. LaunchDesk never asks for your OpenAI password or API key.</div>'+
      '<div><a class="btn accent" href="https://chatgpt.com/" target="_blank" rel="noopener noreferrer">Open ChatGPT ↗</a></div>'+
      '<div class="notice-card"><b>Important</b><p>This browser demo does not embed the ChatGPT consumer subscription or impersonate an OpenAI login. ChatGPT is opened on its official website.</p></div></div>');
  }
  function settingsRow(name,description,control){
    return '<div class="setting-row"><div class="line-main"><b>'+esc(name)+'</b><div class="description">'+esc(description)+'</div></div><div>'+control+'</div></div>';
  }
  function sw(name,value){
    return '<input type="checkbox" data-setting="'+name+'" aria-label="'+name+'" '+(value?'checked':'')+'>';
  }
  function renderSettings(){
    const s=data.settings;
    const select=(name,options,value)=>'<select data-setting="'+name+'" aria-label="'+name+'">'+options.map(o=>'<option value="'+esc(o[0])+'" '+(o[0]===value?'selected':'')+'>'+esc(o[1])+'</option>').join('')+'</select>';
    const group=(heading,rows)=>card(title(heading)+rows);
    return head('Settings','Make LaunchDesk your own — saved automatically in your browser',btn('Export Backup','export')+btn('Import Backup','import')+btn('Reset Demo','reset','','danger'))+
      '<div class="demo-banner"><b>Demo User</b> Settings, notes, tasks, shortcuts and other content persist using localStorage in this browser only.</div>'+
      '<div class="board two">'+group('APPEARANCE',
        settingsRow('Theme','Switch dark and light mode',select('theme',[['dark','Dark'],['light','Light']],s.theme))+
        settingsRow('Accent color','Personalize dashboard highlights','<input type="color" data-setting="accent" value="'+esc(s.accent)+'" aria-label="Accent color">')+
        settingsRow('Compact layout','Reduce padding throughout the interface',sw('compact',s.compact))+
        settingsRow('Reduced motion','Minimize animations',sw('reducedMotion',s.reducedMotion))+
        settingsRow('24-hour clock','Use 24-hour time notation',sw('hour24',s.hour24))+
        settingsRow('Seconds in clock','Show seconds on dashboard',sw('showSeconds',s.showSeconds)))+
      group('DASHBOARD WIDGETS',
        [['showSchedule','Schedule','Current and upcoming events'],['showFocus','Focus timer','Pomodoro card'],['showTasks','Task overview','Counts for your to-dos'],['showNotes','Quick notes','Recent notes'],['showQuickApps','Quick launch','Saved website links'],['showBattery','Battery','Available only in supported browsers'],['showActivity','Activity history','Show activity events']]
        .map(x=>settingsRow(x[1],x[2],sw(x[0],s[x[0]]))).join(''))+
      group('FOCUS TIMER',
        settingsRow('Focus duration','Minutes per focus session','<input type="number" min="1" max="180" data-setting="focusMinutes" value="'+s.focusMinutes+'" style="width:74px">')+
        settingsRow('Break duration','Minutes per break','<input type="number" min="1" max="60" data-setting="breakMinutes" value="'+s.breakMinutes+'" style="width:74px">')+
        settingsRow('Timer alerts','Display an in-page alert when the timer completes',sw('notifyTimer',s.notifyTimer)))+
      group('BACKUP & PRIVACY',
        '<div class="notice-card"><b>Private per-browser storage</b><p>No data is uploaded by this demo. Clearing your browser data or using another device resets your workspace. Export a backup to save it elsewhere.</p></div>'+
        '<div class="form-row" style="margin-top:16px">'+btn('Download JSON backup','export','','accent')+btn('Import JSON backup','import')+btn('Reset everything','reset','','danger')+'</div>')+
      '</div>';
  }
  function renderWidgets(){
    const s=data.settings;
    const count=data.tasks.filter(t=>t.done).length;
    return head('Widgets','Browser-safe versions of LaunchDesk widgets',btn('Customize Widgets','goto-settings'))+
      '<div class="board three">'+card(title('CLOCK')+'<div class="clock-time" id="widget-clock" style="margin-top:16px">'+esc(time(now()))+'</div><div class="muted">'+esc(humanDate(now()))+'</div>')+
      card(title('TASKS')+'<h2 style="font-size:25px">'+count+' / '+data.tasks.length+'</h2><div class="muted">Completed tasks</div>'+btn('Manage tasks','goto-tasks'))+
      card(title('FOCUS TIMER')+'<h2 style="font-size:25px">'+duration(data.focus.remaining)+'</h2><div class="muted">'+(data.focus.running?'Running':'Paused')+'</div>'+btn('Open timer','goto-focus'))+
      card(title('SCHEDULE')+'<div class="stack" style="margin-top:10px">'+(todaySchedules().slice(0,3).map(miniSchedule).join('')||'<div class="muted">No upcoming schedule today</div>')+'</div>')+
      card(title('NOTES')+'<div class="stack" style="margin-top:10px">'+(data.notes.slice(0,3).map(miniNote).join('')||'<div class="muted">No notes yet</div>')+'</div>')+
      card(title('BATTERY')+'<h2 id="widget-battery">'+(battery?battery.level+'%':'Unavailable')+'</h2><div class="muted">The Battery Status API is not available in every browser.</div>')+
      card(title('CPU & RAM')+'<div class="notice-card" style="margin-top:11px"><b>Unavailable in browser</b><p>Websites cannot access the same real-time system monitoring information as the Windows app.</p></div>')+
      card(title('QUICK LINKS')+'<div class="quickapps">'+data.apps.slice(0,5).map(a=>
        '<button class="quickapp" data-action="open-app" data-id="'+esc(a.id)+'"><span class="shortcut-icon">'+esc(a.symbol||'▦')+'</span>'+esc(a.name)+'</button>'
      ).join('')+'</div>')+
      card(title('DATA PERSISTENCE')+'<div class="notice-card" style="margin-top:11px"><b>localStorage enabled</b><p>Changes are automatically saved in this browser. Export a backup from Settings.</p></div>')+'</div>';
  }
  function refreshNotice(){
    const running=runningSchedule();
    const next=nextSchedule();
    $('#notice-text').textContent=(running?'NOW RUNNING: '+running.title:'No task running')+
      '   |   '+(next?'NEXT: '+next.s.title+' at '+next.s.start:'No upcoming schedule');
  }
  function render(){
    applySettings();renderNav();refreshNotice();
    const views={dashboard:renderDashboard,schedule:renderSchedule,tasks:renderTasks,notes:()=>renderNotes(false),apps:renderApps,focus:renderFocus,habits:renderHabits,activity:renderActivity,journal:()=>renderNotes(true),settings:renderSettings,chatgpt:renderChatGPT,widgets:renderWidgets};
    $('#content').innerHTML=views[page]();
  }
  function updateClocks(){
    for(const id of ['live-time','widget-clock']){const el=$('#'+id);if(el)el.textContent=time(now());}
    const d=$('#live-date');if(d)d.textContent=humanDate(now());
    if(page==='dashboard'||page==='schedule')refreshNotice();
    if(page==='focus'){
      const r=$('#big-ring .ring');if(r){
        r.style.setProperty('--pct',focusPercent()+'%');
        const txt=r.querySelector('.ring-inner strong');if(txt)txt.textContent=duration(data.focus.remaining);
      }
    }
  }
  function tick(){
    if(data.focus.running&&data.focus.endAt){
      const remaining=Math.max(0,Math.ceil((data.focus.endAt-Date.now())/1000));
      if(remaining!==data.focus.remaining)data.focus.remaining=remaining;
      if(remaining===0){
        data.focus.running=false;data.focus.endAt=null;
        if(data.focus.mode==='focus') data.focus.completed++;
        logEvent('Completed a '+data.focus.mode+' timer session','focus');
        store();render();
        if(data.settings.notifyTimer)toast('Timer complete! Great work.');
      }
    }
    updateClocks();
  }
  function updateFocus(action,id){
    const f=data.focus;
    if(action==='focus-toggle'){
      if(f.running){f.running=false;f.endAt=null;}
      else{if(f.remaining<=0)f.remaining=(f.mode==='focus'?data.settings.focusMinutes:data.settings.breakMinutes)*60;f.running=true;f.endAt=Date.now()+f.remaining*1000;}
    }else if(action==='focus-reset'){
      f.running=false;f.endAt=null;f.remaining=(f.mode==='focus'?data.settings.focusMinutes:data.settings.breakMinutes)*60;
    }else if(action==='focus-mode'){
      f.mode=id==='break'?'break':'focus';f.running=false;f.endAt=null;f.remaining=(f.mode==='focus'?data.settings.focusMinutes:data.settings.breakMinutes)*60;
    }
    store();render();
  }
  function field(label,name,value='',type='text',opts=null){
    let input;
    if(type==='textarea')input='<textarea name="'+name+'" rows="5">'+esc(value)+'</textarea>';
    else if(type==='select')input='<select name="'+name+'">'+opts.map(o=>'<option value="'+esc(o[0])+'" '+(String(value)===String(o[0])?'selected':'')+'>'+esc(o[1])+'</option>').join('')+'</select>';
    else input='<input name="'+name+'" type="'+type+'" value="'+esc(value)+'" '+(type==='color'?'':'')+' '+(name==='title'||name==='url'||name==='start'||name==='end'?'required':'')+'>';
    return '<div class="field"><label for="dialog-field-'+name+'">'+esc(label)+'</label>'+input.replace('name="'+name+'"','name="'+name+'" id="dialog-field-'+name+'"')+'</div>';
  }
  function openEditor(type,id=''){
    const map={task:'tasks',schedule:'schedules',note:'notes',journal:'journal',app:'apps',habit:'habits'};
    const items=data[map[type]];
    const item=id?items.find(x=>x.id===id):null;
    if(id&&!item){toast('Item no longer exists',true);return;}
    let html='';
    if(type==='task')html=field('Task','title',item?.title||'')+field('Priority','priority',item?.priority||'Normal','select',[['Low','Low'],['Normal','Normal'],['High','High']])+field('Due date (optional)','due',item?.due||'','date');
    if(type==='schedule')html=field('Event title','title',item?.title||'')+
      field('First date','date',item?.date||dateKey(),'date')+
      '<div class="form-row">'+field('Start','start',item?.start||'09:00','time')+field('End','end',item?.end||'10:00','time')+'</div>'+
      field('Repeat','repeat',item?.repeat||'once','select',[['once','Once'],['daily','Daily'],['weekdays','Weekdays'],['weekends','Weekends'],['weekly','Weekly']])+
      field('Color','color',item?.color||'#8c79fc','color');
    if(type==='note'||type==='journal')html=field('Title','title',item?.title||'')+field('Content','body',item?.body||'','textarea')+(type==='journal'?field('Mood','mood',item?.mood||'Reflective','select',[['Reflective','Reflective'],['Happy','Happy'],['Focused','Focused'],['Tired','Tired'],['Excited','Excited']]):'');
    if(type==='app')html=field('Shortcut name','title',item?.name||'')+field('Website address (https://)','url',item?.url||'https://','url')+field('Symbol','symbol',item?.symbol||'▦')+field('Category','category',item?.category||'Website');
    if(type==='habit')html=field('Habit name','title',item?.title||'');
    const heading=(id?'Edit ':'New ')+type[0].toUpperCase()+type.slice(1);
    openModal(heading,'Changes are stored locally in your browser.',html,type,id);
  }
  function openModal(heading,description,fields,type,id){
    const modal=$('#modal');
    modal.hidden=false;
    modal.innerHTML='<div class="modal-dialog" role="dialog" aria-modal="true" aria-labelledby="dialog-title">'+
      '<form id="editor-form" data-type="'+esc(type)+'" data-id="'+esc(id)+'"><h2 id="dialog-title">'+esc(heading)+'</h2><p class="modal-description">'+esc(description)+'</p><div class="stack">'+fields+
      '</div><div class="modal-actions"><button class="btn secondary" type="button" data-action="close-modal">Cancel</button><button class="btn accent" type="submit">Save</button></div></form></div>';
    modal.querySelector('input,textarea,select,button')?.focus();
  }
  function closeModal(){const modal=$('#modal');modal.hidden=true;modal.innerHTML='';}
  function saveEditor(form){
    const type=form.dataset.type,id=form.dataset.id;
    const fields=new FormData(form);const value=(name)=>String(fields.get(name)||'').trim();
    const map={task:'tasks',schedule:'schedules',note:'notes',journal:'journal',app:'apps',habit:'habits'};
    const items=data[map[type]];
    if(!items)return;
    let entry=id?items.find(x=>x.id===id):null;
    if(id&&!entry){toast('Item missing',true);return;}
    if(!entry)entry={id:uid()};
    if(type==='app'){
      if(!value('title'))return toast('Enter a name',true);
      const url=safeUrl(value('url'));
      if(!url)return toast('Only http:// or https:// website links are supported.',true);
      Object.assign(entry,{name:value('title').slice(0,80),url,symbol:value('symbol').slice(0,3)||'▦',category:value('category').slice(0,50)});
    } else {
      if(!value('title'))return toast('Title is required',true);
      entry.title=value('title').slice(0,160);
      if(type==='task'){entry.priority=value('priority');entry.due=value('due');entry.done=!!entry.done;}
      if(type==='schedule'){
        if(!value('date')||!value('start')||!value('end'))return toast('Enter a date and time',true);
        Object.assign(entry,{date:value('date'),start:value('start'),end:value('end'),repeat:value('repeat'),color:validColor(value('color'))?value('color'):data.settings.accent});
      }
      if(type==='note'||type==='journal'){entry.body=value('body').slice(0,12000);entry.updated=new Date().toISOString();if(type==='journal')entry.mood=value('mood');}
    }
    if(!id)items.unshift(entry);
    logEvent((id?'Updated ':'Added ')+type+': '+(entry.title||entry.name));
    store();closeModal();render();toast('Saved in this browser');
  }
  function remove(type,id) {
    const map={task:'tasks',schedule:'schedules',note:'notes',journal:'journal',app:'apps',habit:'habits'};
    const key=map[type];if(!key)return;
    const item=data[key].find(x=>x.id===id);
    if(!item)return;
    if(!confirm('Delete "'+(item.title||item.name)+'"?'))return;
    data[key]=data[key].filter(x=>x.id!==id);
    if(type==='habit') for(const day of Object.keys(data.habitChecks)) data.habitChecks[day]=data.habitChecks[day].filter(v=>v!==id);
    logEvent('Deleted '+type+': '+(item.title||item.name));store();render();toast('Deleted');
  }
  function doExport(){
    const contents=JSON.stringify(data,null,2);
    const blob=new Blob([contents],{type:'application/json'});
    const url=URL.createObjectURL(blob),a=document.createElement('a');
    a.href=url;a.download='LaunchDesk-Demo-Backup-'+dateKey()+'.json';document.body.appendChild(a);a.click();a.remove();
    setTimeout(()=>URL.revokeObjectURL(url),1000);toast('Backup exported');
  }
  function doImport(){
    const picker=document.createElement('input');
    picker.type='file';picker.accept='.json,application/json';
    picker.onchange=async()=>{
      const file=picker.files?.[0];if(!file)return;
      if(file.size>2*1024*1024)return toast('Backup exceeds 2 MB',true);
      try{
        const parsed=JSON.parse(await file.text());
        const proposed=validateImport(parsed);
        if(!confirm('Replace all current Demo User data with this backup?'))return;
        data=proposed;store();render();toast('Backup imported');
      }catch(e){toast('Could not import backup: '+e.message,true);}
    };
    picker.click();
  }
  function perform(action,id=''){
    if(action==='close-modal')return closeModal();
    if(action==='new-task')return openEditor('task');
    if(action==='new-schedule')return openEditor('schedule');
    if(action==='new-note')return openEditor('note');
    if(action==='new-journal')return openEditor('journal');
    if(action==='new-app')return openEditor('app');
    if(action==='new-habit')return openEditor('habit');
    if(action.startsWith('edit-'))return openEditor(action.slice(5),id);
    if(action.startsWith('delete-'))return remove(action.slice(7),id);
    if(action.startsWith('focus-'))return updateFocus(action,id);
    if(action==='goto-settings')return setPage('settings');
    if(action==='goto-tasks')return setPage('tasks');
    if(action==='goto-focus')return setPage('focus');
    if(action==='open-app'){
      const app=data.apps.find(a=>a.id===id);
      if(!app)return;
      const url=safeUrl(app.url);
      if(!url)return toast('Invalid website link',true);
      const tab=window.open(url,'_blank','noopener,noreferrer');
      if(!tab)toast('Allow pop-ups to open this website.',true);
      logEvent('Opened link: '+app.name,'app');store();
      return;
    }
    if(action==='clear-activity'){if(confirm('Clear local activity history?')){data.events=[];store();render();}return;}
    if(action==='export')return doExport();
    if(action==='import')return doImport();
    if(action==='reset'){
      if(!confirm('Reset the entire Demo User workspace? This cannot be undone without a backup.'))return;
      data=defaultData();store();render();toast('Demo workspace reset');
    }
  }
  function bindEvents(){
    document.addEventListener('click',event=>{
      const pageButton=event.target.closest('[data-page]');
      if(pageButton){setPage(pageButton.dataset.page);return;}
      const button=event.target.closest('[data-action]');
      if(button){event.preventDefault();perform(button.dataset.action,button.dataset.id);return;}
      if(event.target===$('#modal'))closeModal();
    });
    $('#reset-workspace').addEventListener('click',()=>perform('reset'));
    document.addEventListener('submit',event=>{
      if(event.target.id!=='editor-form')return;
      event.preventDefault();saveEditor(event.target);
    });
    document.addEventListener('change',event=>{
      const target=event.target;
      if(target.hasAttribute('data-check-task')){
        const item=data.tasks.find(x=>x.id===target.dataset.checkTask);
        if(item){item.done=target.checked;logEvent((item.done?'Completed ':'Reopened ')+'task: '+item.title,'task');store();render();}
      }
      if(target.hasAttribute('data-habit')){
        const day=target.dataset.day,id=target.dataset.habit;
        const checked=new Set(data.habitChecks[day]||[]);
        if(target.checked)checked.add(id);else checked.delete(id);
        data.habitChecks[day]=Array.from(checked);
        store();
      }
      if(target.hasAttribute('data-setting')){
        const key=target.dataset.setting;
        if(!(key in data.settings))return;
        let value=target.type==='checkbox'?target.checked:target.value;
        if(['focusMinutes','breakMinutes'].includes(key)){
          value=Number(value);value=Math.max(1,Math.min(key==='focusMinutes'?180:60,Number.isFinite(value)?Math.round(value):25));
        }
        if(key==='accent'&&!validColor(value))return;
        data.settings[key]=value;
        if(key==='focusMinutes'&&data.focus.mode==='focus'&&!data.focus.running)data.focus.remaining=value*60;
        if(key==='breakMinutes'&&data.focus.mode==='break'&&!data.focus.running)data.focus.remaining=value*60;
        store();render();toast('Setting saved');
      }
    });
    document.addEventListener('input',event=>{
      if(event.target.id==='search-apps'){
        search=event.target.value;
        const pos=event.target.selectionStart;
        const holder=$('#content');
        const newHtml=renderApps();
        holder.innerHTML=newHtml;
        const field=$('#search-apps');field.focus();field.setSelectionRange(pos,pos);
      }
    });
    document.addEventListener('keydown',event=>{
      if(event.key==='Escape'&&!$('#modal').hidden)closeModal();
    });
  }
  async function loadBattery(){
    if(typeof navigator.getBattery!=='function')return;
    try{
      const b=await navigator.getBattery();
      const refresh=()=>{
        battery={level:Math.round(b.level*100),label:b.charging?'Charging':'Not charging'};
        const pct=$('#battery-percent');if(pct)pct.textContent=battery.level+'%';
        const name=$('#battery-label');if(name)name.textContent=battery.label;
        const widget=$('#widget-battery');if(widget)widget.textContent=battery.level+'%';
      };
      refresh();b.addEventListener('levelchange',refresh);b.addEventListener('chargingchange',refresh);
    }catch{}
  }
  applySettings();
  bindEvents();
  render();
  loadBattery();
  setInterval(tick,1000);
})();
