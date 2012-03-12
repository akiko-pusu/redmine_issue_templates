module IssueTemplatesHelper
  def grouped_array(trackers, project_id)
    array = []
    trackers.each {|tracker|
      group = []
      tmpls = IssueTemplate.find(:all, 
        :conditions => ['tracker_id = ? AND project_id = ?',
          item.id, project_id])
      tmpls.each { |x| group.push([x.id, x.title]) }      
      array.push([tracker.name, group])
    }
    return array
  end  
end
