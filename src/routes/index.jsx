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

export default function AppRoutes() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/register" element={<Register />} />
        <Route path="/login" element={<Login />} />
        <Route path="/about" element={<About />} />
        <Route path="/job-details" element={<JobDetails />} />
        <Route path="/profile" element={<Profile />} />
        <Route path="/apply-job" element={<ApplyJob />} />
        <Route path="/post-job" element={<JobPost />} />
        <Route path="/authenticate" element={<Authenticate />} />
        <Route path="/system-error" element={<SystemError />} />
        <Route path="/company-profile" element={<CompanyProfile />} />
        <Route path="/company-posts" element={<CompanyPosts />} />
      </Routes>
    </BrowserRouter>
  );
}
