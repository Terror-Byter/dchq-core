system_url = "https://app.divecentrehq.com/events/widget?public_key=" + public_key

#var system_url = "http://staging.divecentrehq.com/events/widget?public_key=" + public_key;
#system_url = "http://localhost:3000/events/widget?public_key=#{public_key}"
document.write "<iframe frameborder=#{border} width=#{width} height=#{height} src=#{system_url}>"
