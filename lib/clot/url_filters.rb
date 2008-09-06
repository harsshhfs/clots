module Clot
  module UrlFilters
    include ActionView::Helpers::TagHelper

    def object_url(object, class_name = nil)
      if (class_name.nil?)
        class_name = object.dropped_class.to_s.tableize
      end
    '/' + class_name + "/" + object.record_id.to_s    
    end
    
    def get_url(target, class_name = nil)
      if target.is_a? String
        target
      else
        object_url target, class_name
      end    
    end    
    
    def edit_link(target, message = "Edit", class_name = nil)
      url = get_url target, class_name    
      content_tag :a, message, :href => url + "/edit"
    end

    def view_link(target, message = "View", class_name = nil)
      url = get_url target, class_name
      content_tag :a, message, :href => url
    end
    
    def index_url(class_name, message = "Index")
      content_tag :a, message, :href => "/" + class_name.tableize
    end
    
    def delete_link(target, message = "Delete", class_name = nil)
      url = get_url target, class_name
      if @context.has_key? 'auth_token'
        token = @context['auth_token']
        token_string = "var s = document.createElement('input'); s.setAttribute('type', 'hidden'); s.setAttribute('name', 'authenticity_token'); s.setAttribute('value', '" + token + "') ;f.appendChild(s);"
      else
        token_string = ""
      end
      content_tag :a, message, :href => url, :onclick => "if (confirm('Are you sure?')) { var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);" + token_string + "f.submit(); };return false;"
    end

    def stylesheet_url(sheetname)
      stylesheet_url =  "/stylesheets/" + sheetname
      stylesheet_url
    end
    
    def stylesheet_link(url)
    '<link href="'+ url +'"  media="screen" rel="stylesheet" type="text/css" />'
    end
    
    def index_link(controller, message = nil)
      if message.blank?
        controller_array = controller.split("_")
        controller_array.map! {|item| item.capitalize }
        message = controller_array.join(" ") + " Index"      
      end
    '<a href="/' + controller +'">' + message + '</a>'
    end
    
    def new_link(controller, message = nil)
      if message.blank?
        controller_array = controller.split("_")
        controller_array.map! {|item| item.capitalize }
        message = "New "  + controller_array.join(" ")
        message.chomp!("s")
      end
    '<a href="/' + controller +'/new">' + message + '</a>'
    end

    
    def page_link_for(url, page, message)
      "<a href=\"" + url + "?page=" + page.to_s + "\">" + message + "</a>" 
    end
    
    def will_paginate(collection, url)
      total = collection.total_pages
      
      if total <= 1
        return ""
      end
      
      links = '<div class="pagination-links">'
      current = collection.current_page
      if current > 1
        links += page_link_for(url,1, "&lt;&lt;")  + " "
        links += page_link_for(url,current - 1, "&lt;")  + " "
      end     
      
       (1..(total)).each do |index|
        if index != 1
          links += " | "
        end
        
        if index == current
          links += index.to_s
        else
          links += page_link_for(url,index,index.to_s)
        end
      end
      
      if current < total
        links += " " + page_link_for(url, current + 1, "&gt;")
        links += " " + page_link_for(url, total, "&gt;&gt;")
      end           
      
      links += "</div>"
    end    
    
  end
end
