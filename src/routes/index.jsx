import { BrowserRouter, Routes, Route } from "react-router-dom";
import Register from "../pages/Register";
import Login from "../pages/Login";
import Home from "../pages/Home"; // ví dụ
import About from "../pages/About"; // ví dụ
import JobDetails from "../pages/JobDetails";
import Profile from "../pages/Profile";
import ApplyJob from "../pages/ApplyJob";
import JobPost from "../pages/JobPost";
import Authenticate from "../pages/Authenticate";
import SystemError from "../pages/SystemError";
import CompanyProfile from "../pages/CompanyProfile";
import CompanyPosts from "../pages/CompanyPosts";
import RegisterRoleModal from "../components/RegisterRoleModal";
import RegisterCandidate from "../pages/RegisterCandidate";
import RegisterEmployer from "../pages/RegisterEmployer";
import AdminDashboard from "../pages/AdminDashboard"; 
import { ProtectedRoute } from "../components/ProtectedRoute";
import { USER_ROLES } from "../contexts/AuthContext";
import Unauthorized from "../pages/Unauthorized";
import RecruiterDashboard from "../pages/RecruiterDashboard";
export default function AppRoutes() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Phan chung  */}
        <Route path="/" element={<Home />} />
        <Route path="/register" element={<Register />} />
        <Route path="/register-role" element={<RegisterRoleModal />} />
        <Route path="/register-candidate" element={<RegisterCandidate />} />
        <Route path="/register-employer" element={<RegisterEmployer />} />
        <Route path="/login" element={<Login />} />
        <Route path="/about" element={<About />} />

        {/* Public routes */}
        <Route path="/job-details/:id" element={<JobDetails />} />
        <Route path="/company-profile/:id" element={<CompanyProfile />} />
        {/* Protected routes */}
        <Route path="/profile" element={
          <ProtectedRoute>
            <Profile />
          </ProtectedRoute>
        } />
        
        {/* USER only routes */}
        <Route path="/apply-job/:id" element={
          <ProtectedRoute allowedRoles={[USER_ROLES.USER]}>
            <ApplyJob />
          </ProtectedRoute>
        } />
        
        {/* RECRUITER only routes */}
        <Route path="/post-job" element={
          <ProtectedRoute allowedRoles={[USER_ROLES.RECRUITER]}>
            <JobPost />
          </ProtectedRoute>
        } />
        <Route path="/company-posts" element={
          <ProtectedRoute allowedRoles={[USER_ROLES.RECRUITER]}>
            <CompanyPosts />
          </ProtectedRoute>
        } />
        
        {/* ADMIN only routes */}
        {/* <Route path="/admin" element={
          <ProtectedRoute allowedRoles={[USER_ROLES.ADMIN]}>
            <AdminDashboard />
          </ProtectedRoute>
        } /> */}
        <Route path="/admin" element={
          // <ProtectedRoute allowedRoles={[USER_ROLES.ADMIN]}>
            <AdminDashboard />
          // {/* </ProtectedRoute> */}
        } />
        
        {/* Multi-role routes */}
        <Route path="/authenticate" element={
          <ProtectedRoute allowedRoles={[USER_ROLES.RECRUITER, USER_ROLES.ADMIN]}>
            <Authenticate />
          </ProtectedRoute>
        } />

        {/* <Route path="/system-error" element={<SystemError />} /> */}
        <Route path="/unauthorized" element={<Unauthorized />} />
        {/* Nhap */}
        <Route path="/recruiter-dashboard" element= {<RecruiterDashboard />} />
      </Routes>
    </BrowserRouter>
  );
}
