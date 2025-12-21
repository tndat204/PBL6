import { BrowserRouter, Routes, Route } from "react-router-dom";
import Register from "../pages/Register";
import Login from "../pages/Login";
import ForgotPassword from "../pages/ForgotPassword";
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
import RecruiterLayout from "../layouts/RecruiterLayout";

import CVMatching from "../pages/CVMatching";
import LandingPage from "../pages/LandingPage";
import Contact from "../pages/Contact";
import CareerTips from "../pages/CareerTips";

///////////////////////////////////////////////// 
// CANDIDATE ROUTES
///////////////////////////////////////////////////
// import CandidateDashboard from "../pages/CandidateDashboard";


///////////////////////////////////////////////// 
// ADMIN ROUTES
///////////////////////////////////////////////////

import UserManagement from "../pages/UserManagement";
import CompanyManagement from "../pages/CompanyManagement";
import JobManagement from "../pages/JobManagement";
import SkillCategoryManagement from "../pages/SkillCategoryManagement";
import PermissionsManagement from "../pages/PermissionsManagement";
import ReportManagement from "../pages/ReportManagement";
import CVReview from "../pages/CVReview";
import CVReviewResult from "../pages/CVReviewResult";
import AdminLayout from "../layouts/AdminLayout";
import MyApplications from "../pages/MyApplications";

// Recruiter pages
import RecruiterJobManagement from "../pages/RecruiterJobManagement";
import RecruiterApplicationManagement from "../pages/RecruiterApplicationManagement";
import RecruiterCompanyManagement from "../pages/RecruiterCompanyManagement";
import RecruiterProfileManagement from "../pages/RecruiterProfileManagement";

export default function AppRoutes() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Phan chung  */}
        <Route path="/" element={<LandingPage />} />
        <Route path="/jobs" element={<Home />} />
        <Route path="/register" element={<Register />} />
        <Route path="/register-role" element={<RegisterRoleModal />} />
        <Route path="/register-candidate" element={<RegisterCandidate />} />
        <Route path="/register-employer" element={<RegisterEmployer />} />
        <Route path="/login" element={<Login />} />
        <Route path="/forgot-password" element={<ForgotPassword />} />
        <Route path="/about" element={<About />} />
        <Route path="/contact" element={<Contact />} />
        <Route path="/career-tips" element={<CareerTips />} />
        {/* New routes added here */}
        <Route path="/cv-review" element={<CVReview />} />
        <Route path="/cv-review/results" element={<CVReviewResult />} />
        <Route path="/cv-matching" element={
          <ProtectedRoute allowedRoles={[USER_ROLES.ADMIN, USER_ROLES.RECRUITER]}>
            <CVMatching />
          </ProtectedRoute>
        } />
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
        <Route path="/my-applications" element={
          <ProtectedRoute allowedRoles={[USER_ROLES.USER]}>
            <MyApplications />
          </ProtectedRoute>
        } />

        {/* RECRUITER only routes */}
        <Route path="/post-job" element={
          <ProtectedRoute allowedRoles={[USER_ROLES.RECRUITER]}>
            <JobPost />
          </ProtectedRoute>
        } />
        <Route path="/company-posts" element={
          <ProtectedRoute allowedRoles={[USER_ROLES.RECRUITER, USER_ROLES.ADMIN]}>
            <CompanyPosts />
          </ProtectedRoute>
        } />


        {/* ADMIN only routes */}
        {/* <Route path="/admin" element={
          <ProtectedRoute allowedRoles={[USER_ROLES.ADMIN]}>
            <AdminDashboard />
          </ProtectedRoute>
        } /> */}
        {/* ADMIN routes with Layout */}
        <Route path="/admin" element={
          <ProtectedRoute allowedRoles={[USER_ROLES.ADMIN]}>
            <AdminLayout />
          </ProtectedRoute>
        }>
          <Route index element={<AdminDashboard />} />
          <Route path="users" element={<UserManagement />} />
          <Route path="companies" element={<CompanyManagement />} />
          <Route path="jobs" element={<JobManagement />} />
          <Route path="reports" element={<ReportManagement />} />
          <Route path="categories" element={<SkillCategoryManagement />} />
          <Route path="permissions" element={<PermissionsManagement />} />
        </Route>

        {/* Multi-role routes */}
        <Route path="/authenticate" element={
          <ProtectedRoute allowedRoles={[USER_ROLES.RECRUITER, USER_ROLES.ADMIN]}>
            <Authenticate />
          </ProtectedRoute>
        } />

        {/* <Route path="/system-error" element={<SystemError />} /> */}
        <Route path="/unauthorized" element={<Unauthorized />} />

        {/* RECRUITER routes with Layout */}
        <Route path="/recruiter" element={
          <ProtectedRoute allowedRoles={[USER_ROLES.RECRUITER]}>
            <RecruiterLayout />
          </ProtectedRoute>
        }>
          <Route index element={<RecruiterDashboard />} />
          <Route path="jobs" element={<RecruiterJobManagement />} />
          <Route path="applications" element={<RecruiterApplicationManagement />} />
          <Route path="company" element={<RecruiterCompanyManagement />} />
          <Route path="profile" element={<RecruiterProfileManagement />} />
        </Route>

      </Routes>
    </BrowserRouter>
  );
}
