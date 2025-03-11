# **User Manual** 

#### **Login**

1. After opening the app, you will first see the login interface.
2. Enter your Duke NetID and password to log in.
3. Once successfully logged in, the app will save your login status.

#### **Main Interface**

The app is divided into two main tabs:

- **People List**: Displays all personnel information, supporting various sorting and search functions.
- **Team View**: Displays personnel grouped by team, suitable for team collaboration viewing.

#### **People List Functions**

- **Search**: Enter keywords in the top search bar to instantly filter the people list.

- **Sort**: 

  Click the sort button in the upper left corner to select sorting method:

  - Sort by role (Professor, TA, Student, etc.)
  - Sort by gender
  - Sort by study plan
  - Sort by program
  - Sort by first name
  - Sort by last name

- Download Data: 

  Click the "Download" button to select download mode:

  - Replace mode: Clear local data, completely replace with server data
  - Update mode: Only update existing data, preserve locally added data

- **Add Person**: Click the "+" button in the upper right corner to add a new person.

- **Edit/Delete**: Swipe left on a person entry to display edit and delete options. 

#### **Team View Functions**

- Display all personnel grouped by team name.
- Scroll horizontally to browse members of each team.
- Click on a member's avatar to view detailed information (view-only mode). 

#### **Person Detail Page**

- **Flip View**: Click anywhere to flip the card and view information on both sides.
- **Front**: Displays basic information, including avatar, name, origin, hobbies, etc.
- **Back**: Displays detailed information, including academic information, skills, languages, etc.
- **Edit Function**: Click the "Edit" button on the back to enter edit mode.
- **Upload Function**: Click "Upload" on the back to upload your own information to the server (limited to your own information only). 

#### **Adding a New Person**

1. Click the "+" button in the upper right corner of the people list.
2. Fill in required information (DUID, NetID, name, origin, etc.).
3. Select gender, role, program, and plan.
4. Optionally add avatar, hobbies, and skill languages.
5. Click "Save" to save. 

#### **Data Synchronization**

- Download operations display a progress indicator, visually showing download progress.
- On first run, the app automatically loads your personal information.
- After each download, data is automatically saved to the local database.



# **Innovation Points**

**Custom FlowLayout System**: Implemented a flow layout for language tags, allowing tags to naturally wrap, improving space utilization. 

**Flip Animation**: Used 3D effects to implement card flipping, enhancing user experience. 

**Progress Indicator Optimization**: Download progress indicator uses circular progress bar and gradient animations, providing a more intuitive visual effect. 

**Component Color Matching**: Some components have their own colors, making the interface less monotonous.



# AI Using

The use of AI primarily focuses on page layout and test writing.
