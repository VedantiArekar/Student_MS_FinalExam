// Student Management System - frontend logic (vanilla JavaScript).
// This file talks to the Rails JSON API using fetch() and updates the page
// without reloading it.

const API_URL = "/api/students";

// ---------------------------------------------------------------
// 1. Find the HTML elements we need
// ---------------------------------------------------------------
const messageBox = document.getElementById("message");
const totalCount = document.getElementById("total-count");
const searchInput = document.getElementById("search-input");
const addButton = document.getElementById("add-button");
const formSection = document.getElementById("form-section");
const formTitle = document.getElementById("form-title");
const formErrors = document.getElementById("form-errors");
const studentForm = document.getElementById("student-form");
const submitButton = document.getElementById("submit-button");
const cancelButton = document.getElementById("cancel-button");
const studentsBody = document.getElementById("students-body");
const emptyMessage = document.getElementById("empty-message");
const detailsDialog = document.getElementById("details-dialog");
const detailsList = document.getElementById("details-list");
const detailsClose = document.getElementById("details-close");

// null  = the form is adding a NEW student
// a number = the form is editing the student with that id
let editingId = null;

let messageTimer = null;
let searchTimer = null;

// ---------------------------------------------------------------
// 2. Helper: send a request to the API
// ---------------------------------------------------------------
// Returns the parsed JSON. If the server answers with an error
// (for example 422 validation errors), it throws an Error whose
// "messages" property holds the list of error texts.
async function apiRequest(url, options = {}) {
  let response;

  try {
    response = await fetch(url, {
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      ...options
    });
  } catch (networkError) {
    throw new Error("Cannot reach the server. Please try again.");
  }

  // If the body is not JSON (unexpected server error), use an empty object
  const data = await response.json().catch(() => ({}));

  if (!response.ok) {
    const messages = data.errors || [data.error || `Server error (${response.status})`];
    const error = new Error(messages.join(", "));
    error.messages = messages;
    throw error;
  }

  return data;
}

// ---------------------------------------------------------------
// 3. Messages
// ---------------------------------------------------------------
// type is "success" (green) or "error" (red)
function showMessage(text, type = "success") {
  messageBox.textContent = text;
  messageBox.className = `message message-${type}`;
  messageBox.hidden = false;

  // Hide the message automatically after 5 seconds
  clearTimeout(messageTimer);
  messageTimer = setTimeout(() => {
    messageBox.hidden = true;
  }, 5000);
}

function showFormErrors(messages) {
  formErrors.replaceChildren();
  messages.forEach((text) => {
    const line = document.createElement("div");
    line.textContent = text;
    formErrors.appendChild(line);
  });
  formErrors.hidden = false;
}

function hideFormErrors() {
  formErrors.replaceChildren();
  formErrors.hidden = true;
}

// ---------------------------------------------------------------
// 4. Show the students in the table
// ---------------------------------------------------------------
// We use textContent (not innerHTML) so that text typed by users
// can never be run as HTML or JavaScript.
function makeCell(text) {
  const cell = document.createElement("td");
  cell.textContent = text;
  return cell;
}

function makeButton(label, className, onClick) {
  const button = document.createElement("button");
  button.type = "button";
  button.textContent = label;
  button.className = `btn btn-small ${className}`;
  button.addEventListener("click", onClick);
  return button;
}

function makeActionsCell(student) {
  const cell = document.createElement("td");
  cell.className = "actions";
  cell.append(
    makeButton("View", "btn-secondary", () => viewStudent(student.id)),
    makeButton("Edit", "btn-secondary", () => editStudent(student.id)),
    makeButton("Delete", "btn-danger", () => deleteStudent(student))
  );
  return cell;
}

function renderStudents(students) {
  studentsBody.replaceChildren(); // remove the old rows
  emptyMessage.hidden = students.length > 0;

  students.forEach((student) => {
    const row = document.createElement("tr");
    row.append(
      makeCell(student.id),
      makeCell(student.full_name),
      makeCell(student.email),
      makeCell(student.course),
      makeCell(student.semester),
      makeActionsCell(student)
    );
    studentsBody.appendChild(row);
  });
}

// ---------------------------------------------------------------
// 5. Load students (also used for searching)
// ---------------------------------------------------------------
// GET /api/students?search=...
async function loadStudents() {
  try {
    const term = encodeURIComponent(searchInput.value.trim());
    const data = await apiRequest(`${API_URL}?search=${term}`);

    totalCount.textContent = data.total;
    renderStudents(data.students);
  } catch (error) {
    showMessage(error.message, "error");
  }
}

// ---------------------------------------------------------------
// 6. The add / edit form
// ---------------------------------------------------------------
// openForm()         -> empty form to add a student
// openForm(student)  -> form filled with the student's data to edit
function openForm(student = null) {
  editingId = student ? student.id : null;

  formTitle.textContent = student ? "Edit Student" : "Add Student";
  submitButton.textContent = student ? "Update Student" : "Save Student";

  studentForm.elements.full_name.value = student ? student.full_name : "";
  studentForm.elements.email.value = student ? student.email : "";
  studentForm.elements.course.value = student ? student.course : "";
  studentForm.elements.semester.value = student ? student.semester : "";

  hideFormErrors();
  formSection.hidden = false;
  studentForm.elements.full_name.focus();
  formSection.scrollIntoView();
}

function closeForm() {
  formSection.hidden = true;
  studentForm.reset();
  hideFormErrors();
  editingId = null;
}

// POST /api/students        (add)
// PATCH /api/students/:id   (edit)
async function saveStudent(event) {
  event.preventDefault(); // stop the browser from reloading the page
  hideFormErrors();

  const body = {
    student: {
      full_name: studentForm.elements.full_name.value,
      email: studentForm.elements.email.value,
      course: studentForm.elements.course.value,
      semester: studentForm.elements.semester.value
    }
  };

  const isEditing = editingId !== null;
  const url = isEditing ? `${API_URL}/${editingId}` : API_URL;
  const method = isEditing ? "PATCH" : "POST";

  submitButton.disabled = true; // avoid double clicks

  try {
    const data = await apiRequest(url, { method, body: JSON.stringify(body) });

    closeForm();
    showMessage(data.message, "success");
    await loadStudents(); // refresh the table and the total
  } catch (error) {
    showFormErrors(error.messages || [error.message]);
  } finally {
    submitButton.disabled = false;
  }
}

// ---------------------------------------------------------------
// 7. View, edit and delete one student
// ---------------------------------------------------------------
function addDetail(label, value) {
  const term = document.createElement("dt");
  term.textContent = label;
  const description = document.createElement("dd");
  description.textContent = value;
  detailsList.append(term, description);
}

// GET /api/students/:id
async function viewStudent(id) {
  try {
    const data = await apiRequest(`${API_URL}/${id}`);
    const student = data.student;

    detailsList.replaceChildren();
    addDetail("ID", student.id);
    addDetail("Full name", student.full_name);
    addDetail("Email", student.email);
    addDetail("Course", student.course);
    addDetail("Semester", student.semester);
    addDetail("Created", new Date(student.created_at).toLocaleString());
    addDetail("Last updated", new Date(student.updated_at).toLocaleString());

    detailsDialog.showModal();
  } catch (error) {
    showMessage(error.message, "error");
  }
}

// GET /api/students/:id, then fill the form
async function editStudent(id) {
  try {
    const data = await apiRequest(`${API_URL}/${id}`);
    openForm(data.student);
  } catch (error) {
    showMessage(error.message, "error");
  }
}

// DELETE /api/students/:id (after the user confirms)
async function deleteStudent(student) {
  const confirmed = window.confirm(`Are you sure you want to delete ${student.full_name}?`);
  if (!confirmed) {
    return;
  }

  try {
    const data = await apiRequest(`${API_URL}/${student.id}`, { method: "DELETE" });

    if (editingId === student.id) {
      closeForm(); // the student being edited no longer exists
    }
    showMessage(data.message, "success");
    await loadStudents();
  } catch (error) {
    showMessage(error.message, "error");
  }
}

// ---------------------------------------------------------------
// 8. Connect the buttons and fields to the functions above
// ---------------------------------------------------------------
addButton.addEventListener("click", () => openForm());
cancelButton.addEventListener("click", closeForm);
studentForm.addEventListener("submit", saveStudent);
detailsClose.addEventListener("click", () => detailsDialog.close());

// Search while typing. We wait 300 ms after the last key press,
// so we do not send a request for every single letter.
searchInput.addEventListener("input", () => {
  clearTimeout(searchTimer);
  searchTimer = setTimeout(loadStudents, 300);
});

// Load the students when the page opens
loadStudents();
