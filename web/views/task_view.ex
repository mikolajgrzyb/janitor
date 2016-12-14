defmodule Janitor.TaskView do
  use Janitor.Web, :view

  def render("index.json", %{tasks: tasks}) do
    %{tasks: render_many(tasks, __MODULE__, "task.json", as: :task)}
  end
  def render("task.json", %{task: task}) do
    %{
      id: task.id,
      content: task.content,
    }
  end

  def render("create.json", %{task: task}) do
    task
    |> Map.from_struct
    |> Map.take([:id, :content, :day_id, :user_id])
  end

  def render("update.json", %{task: task}) do
    task
    |> Map.from_struct
    |> Map.take([:id, :content, :day_id, :user_id])
  end

  def render("destroy.json", %{task: task}) do
    task
    |> Map.from_struct
    |> Map.take([:id])
  end

  def render("error.json", %{changeset: changeset}) do
    %{errors: changeset |> translate_errors()}
  end
end
