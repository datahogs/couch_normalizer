defmodule CouchNormalizer.Scenario.FieldMethods do


  @doc false
  defmacro field(name) do
    quote do: field(var!(body), unquote(name))
  end

  @doc false
  defmacro field(:not_found, _name) do
    quote do: nil
  end

  @doc false
  defmacro field(body, name) do
    quote do
      { body, name } = { unquote(body), unquote(name) }
      HashDict.get(body, to_binary(name), :nil)
    end
  end

  @doc false
  defmacro remove_field(name) do
    quote do
      var!(body) = remove_field(var!(body), unquote(name))
    end
  end

  @doc false
  defmacro remove_field(body, name) do
    quote do
      { body, name } = { unquote(body), unquote(name) }
      HashDict.delete(body, to_binary(name))
    end
  end

  @doc false
  defmacro remove_fields(names) do
    removers = lc name inlist names, do: quote(do: remove_field(unquote(name)))
    quote do: unquote_splicing(removers)
  end

  @doc false
  defmacro rename_field(name, new_name) do
    quote do
      { name, new_name } = { unquote(name), unquote(new_name) }
      update_field(name, new_name, field(var!(body), name))
    end
  end

  @doc false
  defmacro update_field(name, value) do
    quote do
      { name, value } = { unquote(name), unquote(value) }
      if field(name), do: create_field(name, value)
    end
  end

  @doc false
  defmacro update_field(name, new_name, value) do
    quote do
      { name, new_name, value } = { unquote(name), unquote(new_name), unquote(value) }
      if field(name) do
        remove_field(name)
        create_field(new_name, value)
      end
    end
  end

  @doc false
  defmacro create_field(name, value) do
    quote do
      { name, value } = { unquote(name), unquote(value) }
      var!(body)      = create_field(var!(body), name, value)
    end
  end

  @doc false
  defmacro create_field(body, name, value) do
    quote do
      { body, name, value } = { unquote(body), unquote(name), unquote(value)}
      HashDict.put(body, to_binary(name), value)
    end
  end

end