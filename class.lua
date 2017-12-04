__make_new_instance = function(self,param)
  local h = {}
  h["&"] = self
  for k,v in pairs(self.methods) do
    h[k] = v
  end
  setmetatable(h,self.overloads)
  self.construct(h,param)
  return h
end

__class_inherit_class = function(self,source)
  for k,v in pairs(source.methods) do
    self.methods[k] = v
  end
  for k,v in pairs(source.overloads) do
    self.overloads[k] = v
  end
end

__default_constructor = function(obj,param)
end

__class_constructor = function(obj,param)
  obj.name = param
  obj.methods = {}
  obj.overloads = {}
  obj.overloads.__tostring = __default_object_to_string
end

__default_object_to_string = function(self)
  return "object:" .. self["&"].name
end

__build_class_class = function()
  local h = {}
  h["&"] = h
  h.name = "class"
  h.methods = {}
  h.overloads = {}
  h.construct = __class_constructor
  h.methods.construct = __default_constructor
  h.new = __make_new_instance
  h.methods.new = __make_new_instance
  h.inherit = __class_inherit_class
  h.methods.inherit = __class_inherit_class
  h.overloads.__call = __make_new_instance
  h.overloads.__tostring = __default_object_to_string
  setmetatable(h,h.overloads)
  return h
end

class = __build_class_class()

classtype = function(obj)
  return obj["&"]
end

classname = function(obj)
  return obj["&"].name
end

is_object = function(obj)
  local helper
  helper = function(thing)
    if thing["&"]["&"]~=class then
      error()
    end
  end
  if pcall(helper,obj) then
    return true
  end
  return false
end

shallowcopy = function(obj)
  if type(obj)~="table" then
    return obj
  end
  local h = {}
  for k,v in pairs(obj) do
    h[k] = v
  end
  return h
end

deepcopy = function(obj)
  if type(obj)~="table" then
    return obj
  end
  if is_object(obj) then
    if classtype(obj)==class then
      return obj
    end
  end
  local h = {}
  for k,v in pairs(obj) do
    h[k] = deepcopy(v)
  end
  return h
end
