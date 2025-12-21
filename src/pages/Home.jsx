import SearchBar from "../components/SearchBar";
import JobFilters from "../components/JobFilters";
import JobList from "../components/JobList";
import MainLayout from "../layouts/MainLayout";
import { useEffect, useState } from "react";
import { jobService } from "../services";

function Home() {
  const [jobs, setJobs] = useState([]);
  const [filteredJobs, setFilteredJobs] = useState([]);

  // Filter states
  const [filters, setFilters] = useState({
    keyword: '',
    location: '',
    jobType: '',
    company: '',
    category: '',
    workTypes: [],
    salaryRange: ''
  });

  useEffect(() => {
    async function fetchJobs() {
      try {
        const data = await jobService.getAllJobs();
        const jobsData = data.result || data;
        setJobs(jobsData);
        setFilteredJobs(jobsData); // Initially show all jobs
      } catch (err) {
        console.error("Lỗi khi lấy danh sách job:", err);
        setJobs([]);
        setFilteredJobs([]);
      }
    }
    fetchJobs();
  }, []);

  // Filter jobs whenever filters change
  useEffect(() => {
    let filtered = [...jobs];

    // Filter by keyword (title or description)
    if (filters.keyword) {
      filtered = filtered.filter(job =>
        job.title?.toLowerCase().includes(filters.keyword.toLowerCase()) ||
        job.description?.toLowerCase().includes(filters.keyword.toLowerCase())
      );
    }

    // Filter by location
    if (filters.location) {
      filtered = filtered.filter(job =>
        job.location?.toLowerCase().includes(filters.location.toLowerCase())
      );
    }

    // Filter by job type
    if (filters.jobType) {
      filtered = filtered.filter(job =>
        job.jobType?.toLowerCase() === filters.jobType.toLowerCase()
      );
    }

    // Filter by company
    if (filters.company) {
      filtered = filtered.filter(job =>
        job.companyName?.toLowerCase().includes(filters.company.toLowerCase())
      );
    }

    // Filter by category
    if (filters.category) {
      filtered = filtered.filter(job =>
        job.category?.toLowerCase().includes(filters.category.toLowerCase())
      );
    }

    // Filter by work types (checkboxes)
    if (filters.workTypes.length > 0) {
      filtered = filtered.filter(job =>
        filters.workTypes.some(type =>
          job.jobType?.toLowerCase().includes(type.toLowerCase())
        )
      );
    }

    // Filter by salary range
    if (filters.salaryRange) {
      filtered = filtered.filter(job => {
        const salary = parseInt(job.salary) || 0;
        switch (filters.salaryRange) {
          case '10-15':
            return salary >= 10000000 && salary <= 15000000;
          case '15-25':
            return salary >= 15000000 && salary <= 25000000;
          case '25+':
            return salary > 25000000;
          default:
            return true;
        }
      });
    }

    setFilteredJobs(filtered);
  }, [filters, jobs]);

  const handleSearch = (searchFilters) => {
    setFilters(prev => ({ ...prev, ...searchFilters }));
  };

  const handleFilterChange = (newFilters) => {
    setFilters(prev => ({ ...prev, ...newFilters }));
  };

  return (
    <MainLayout showBanner={true}>
      {/* SearchBar floating */}
      <div className="relative -mt-24 z-20">
        <SearchBar onSearch={handleSearch} />
      </div>

      {/* Main content: 12 column grid */}
      <div className="grid grid-cols-12 gap-6 mt-10">
        {/* Left Filter */}
        <aside className="col-span-12 lg:col-span-3 lg:sticky lg:top-24 h-max">
          <JobFilters onFilterChange={handleFilterChange} />
        </aside>

        {/* Center Job Listings */}
        <main className="col-span-12 lg:col-span-6">
          <div className="mb-4 text-gray-600">
            Tìm thấy <span className="font-semibold text-gray-900">{filteredJobs.length}</span> công việc
          </div>
          <JobList jobs={filteredJobs} columns={1} />
        </main>

        {/* Right Advertisement Section */}
        <aside className="col-span-12 lg:col-span-3 lg:sticky lg:top-24 h-max space-y-6">
          {/* Featured Companies Ad */}
          <div className="bg-gradient-to-br from-emerald-500 to-cyan-600 rounded-xl p-6 text-white shadow-lg">
            <h3 className="text-lg font-bold mb-3">Featured Companies</h3>
            <p className="text-sm text-emerald-50 mb-4">
              Join top companies hiring now!
            </p>
            <button className="w-full bg-white text-emerald-600 py-2 rounded-lg font-semibold hover:bg-emerald-50 transition">
              Explore Companies
            </button>
          </div>

          {/* Career Tips Ad */}
          <div className="bg-white rounded-xl p-6 shadow-md border border-slate-200">
            <h3 className="text-lg font-bold mb-3 text-slate-900">Career Tips</h3>
            <div className="space-y-3">
              <div className="flex items-start space-x-2">
                <span className="text-emerald-500 mt-1">📌</span>
                <p className="text-sm text-slate-600">How to write a perfect resume</p>
              </div>
              <div className="flex items-start space-x-2">
                <span className="text-emerald-500 mt-1">📌</span>
                <p className="text-sm text-slate-600">Top interview questions 2024</p>
              </div>
              <div className="flex items-start space-x-2">
                <span className="text-emerald-500 mt-1">📌</span>
                <p className="text-sm text-slate-600">Salary negotiation tips</p>
              </div>
            </div>
            <button className="w-full mt-4 border-2 border-slate-900 text-slate-900 py-2 rounded-lg font-medium hover:bg-slate-900 hover:text-white transition">
              Read More
            </button>
          </div>

          {/* Premium Ad */}
          <div className="bg-gradient-to-br from-slate-800 to-slate-900 rounded-xl p-6 text-white shadow-lg">
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-lg font-bold">Go Premium</h3>
              <span className="bg-yellow-500 text-slate-900 text-xs font-bold px-2 py-1 rounded">PRO</span>
            </div>
            <p className="text-sm text-slate-300 mb-4">
              Get unlimited access to exclusive jobs and features
            </p>
            <ul className="space-y-2 mb-4">
              <li className="flex items-center text-sm">
                <span className="text-emerald-400 mr-2">✓</span>
                Priority job applications
              </li>
              <li className="flex items-center text-sm">
                <span className="text-emerald-400 mr-2">✓</span>
                Advanced search filters
              </li>
              <li className="flex items-center text-sm">
                <span className="text-emerald-400 mr-2">✓</span>
                Career coaching sessions
              </li>
            </ul>
            <button className="w-full bg-emerald-500 hover:bg-emerald-600 text-white py-2 rounded-lg font-semibold transition">
              Upgrade Now
            </button>
          </div>

          {/* Job Alert Ad */}
          <div className="bg-blue-50 rounded-xl p-6 border-2 border-blue-200">
            <h3 className="text-lg font-bold mb-2 text-slate-900">Job Alerts</h3>
            <p className="text-sm text-slate-600 mb-4">
              Get notified about new jobs matching your profile
            </p>
            <input
              type="email"
              placeholder="Enter your email"
              className="w-full px-4 py-2 border border-slate-300 rounded-lg mb-3 text-sm focus:ring-2 focus:ring-blue-500 focus:outline-none"
            />
            <button className="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-lg font-medium transition">
              Subscribe
            </button>
          </div>
        </aside>
      </div>
    </MainLayout>
  );
}

export default Home;