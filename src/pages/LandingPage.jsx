import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { MagnifyingGlassIcon, MapPinIcon, ChevronDownIcon } from "@heroicons/react/24/outline";

export default function LandingPage() {
    const navigate = useNavigate();
    const [searchKeyword, setSearchKeyword] = useState("");
    const [searchLocation, setSearchLocation] = useState("");

    const handleSearch = (e) => {
        e.preventDefault();
        // Navigate to home page with search params
        navigate(`/?keyword=${searchKeyword}&location=${searchLocation}`);
    };

    const popularSearches = [
        "Digital Marketing",
        "UI/UX Design",
        "Affiliate Marketing",
        "User Experience Design",
        "Health",
        "Art Studio",
        "Business & Finance",
        "Information Technology",
    ];

    const trustedCompanies = [
        { name: "Verifiable", logo: "https://via.placeholder.com/120x40?text=Verifiable" },
        { name: "BBC", logo: "https://via.placeholder.com/120x40?text=BBC" },
        { name: "Whole Foods", logo: "https://via.placeholder.com/120x40?text=Whole+Foods" },
        { name: "The Guardian", logo: "https://via.placeholder.com/120x40?text=The+Guardian" },
        { name: "Patreon", logo: "https://via.placeholder.com/120x40?text=Patreon" },
    ];

    return (
        <div className="min-h-screen bg-white">
            {/* Header */}
            <header className="bg-gradient-to-br from-slate-700 via-slate-800 to-slate-900 text-white">
                <nav className="container mx-auto px-6 py-4 flex items-center justify-between">
                    <div className="flex items-center space-x-2">
                        <div className="text-2xl font-bold">IT JOB HUNT</div>
                    </div>

                    <div className="hidden md:flex items-center space-x-8">
                        <div className="relative group">
                            <button className="flex items-center space-x-1 hover:text-emerald-400 transition">
                                <span>Job Seekers</span>
                                <ChevronDownIcon className="w-4 h-4" />
                            </button>
                        </div>
                        <div className="relative group">
                            <button className="flex items-center space-x-1 hover:text-emerald-400 transition">
                                <span>Employers</span>
                                <ChevronDownIcon className="w-4 h-4" />
                            </button>
                        </div>
                        <button
                            onClick={() => navigate("/post-job")}
                            className="hover:text-emerald-400 transition"
                        >
                            Post a Job
                        </button>
                    </div>

                    <button
                        onClick={() => navigate("/login")}
                        className="px-6 py-2 border-2 border-white rounded-full hover:bg-white hover:text-slate-800 transition"
                    >
                        Log in
                    </button>
                </nav>

                {/* Hero Section */}
                <div className="container mx-auto px-6 py-20 text-center">
                    <h1 className="text-5xl md:text-6xl font-bold mb-4 leading-tight">
                        Find the perfect
                        <br />
                        profession for you
                    </h1>
                    <p className="text-lg text-slate-300 mb-12">
                        Get more than 5000+ active jobs for both local & globally
                    </p>

                    {/* Search Bar */}
                    <form onSubmit={handleSearch} className="max-w-4xl mx-auto">
                        <div className="bg-white/10 backdrop-blur-md rounded-2xl p-2 flex flex-col md:flex-row gap-2 items-center">
                            <div className="flex-1 flex items-center bg-slate-700/50 rounded-xl px-4 py-3 w-full">
                                <MagnifyingGlassIcon className="w-5 h-5 text-slate-400 mr-3" />
                                <input
                                    type="text"
                                    placeholder="Search by keyword or interest"
                                    value={searchKeyword}
                                    onChange={(e) => setSearchKeyword(e.target.value)}
                                    className="bg-transparent text-white placeholder-slate-400 outline-none w-full"
                                />
                            </div>

                            <div className="flex-1 flex items-center bg-slate-700/50 rounded-xl px-4 py-3 w-full">
                                <MapPinIcon className="w-5 h-5 text-slate-400 mr-3" />
                                <input
                                    type="text"
                                    placeholder="Location or Postcode"
                                    value={searchLocation}
                                    onChange={(e) => setSearchLocation(e.target.value)}
                                    className="bg-transparent text-white placeholder-slate-400 outline-none w-full"
                                />
                            </div>

                            <button
                                type="submit"
                                className="px-8 py-3 bg-emerald-500 hover:bg-emerald-600 text-white font-semibold rounded-xl transition shadow-lg shadow-emerald-500/50"
                            >
                                Search
                            </button>
                        </div>
                    </form>

                    {/* Popular Searches */}
                    <div className="mt-8">
                        <p className="text-slate-300 mb-4">Popular Search</p>
                        <div className="flex flex-wrap justify-center gap-3">
                            {popularSearches.map((search, index) => (
                                <button
                                    key={index}
                                    onClick={() => {
                                        setSearchKeyword(search);
                                        navigate(`/?keyword=${search}`);
                                    }}
                                    className="px-4 py-2 bg-slate-700/50 hover:bg-slate-600/50 rounded-full text-sm border border-slate-600 hover:border-emerald-500 transition"
                                >
                                    {search}
                                </button>
                            ))}
                        </div>
                    </div>
                </div>
            </header>

            {/* Trusted Companies Section */}
            <section className="py-16 bg-slate-50">
                <div className="container mx-auto px-6">
                    <div className="flex flex-wrap items-center justify-center gap-12 opacity-60">
                        {trustedCompanies.map((company, index) => (
                            <div key={index} className="grayscale hover:grayscale-0 transition">
                                <img
                                    src={company.logo}
                                    alt={company.name}
                                    className="h-10 object-contain"
                                />
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* Professional Service Section */}
            <section className="py-20">
                <div className="container mx-auto px-6">
                    <div className="grid md:grid-cols-2 gap-12 items-center">
                        {/* Left - Profile Card Preview */}
                        <div className="relative">
                            <div className="bg-gradient-to-br from-slate-100 to-slate-200 rounded-3xl p-8 shadow-2xl">
                                <div className="bg-white rounded-2xl p-6 shadow-lg">
                                    <div className="flex items-start justify-between mb-6">
                                        <div className="flex items-center space-x-4">
                                            <div className="w-16 h-16 bg-gradient-to-br from-emerald-400 to-cyan-500 rounded-full flex items-center justify-center text-white font-bold text-xl">
                                                AG
                                            </div>
                                            <div>
                                                <h3 className="font-bold text-lg">Abdul Gaffar</h3>
                                                <p className="text-slate-600 text-sm">Businessman</p>
                                            </div>
                                        </div>
                                        <button className="text-slate-400 hover:text-slate-600">
                                            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                                                <path d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z" />
                                            </svg>
                                        </button>
                                    </div>

                                    <div className="space-y-3">
                                        <div className="flex items-center justify-between py-3 border-b">
                                            <span className="text-slate-600">Full Name</span>
                                            <span className="flex items-center text-emerald-600 font-medium">
                                                <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                                                </svg>
                                                Verified
                                            </span>
                                        </div>
                                        <div className="flex items-center justify-between py-3 border-b">
                                            <span className="text-slate-600">Email Account</span>
                                            <span className="flex items-center text-emerald-600 font-medium">
                                                <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                                                </svg>
                                                Verified
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Right - Content */}
                        <div>
                            <h2 className="text-4xl font-bold mb-6 text-slate-900">
                                We provide highly
                                <br />
                                professional service
                            </h2>
                            <p className="text-slate-600 mb-8 leading-relaxed">
                                One place to manage all your provider data and workflows—onboarding,
                                network management, and everything in between.
                            </p>

                            <div className="space-y-6">
                                <div className="flex items-start space-x-3">
                                    <div className="flex-shrink-0 w-6 h-6 bg-emerald-500 rounded-full flex items-center justify-center text-white mt-1">
                                        <span className="text-sm">→</span>
                                    </div>
                                    <div>
                                        <h4 className="font-semibold text-lg mb-1">Verified Jobs</h4>
                                        <p className="text-slate-600">
                                            We source jobs directly from employer websites so you can be sure
                                            they're legit.
                                        </p>
                                    </div>
                                </div>

                                <div className="flex items-start space-x-3">
                                    <div className="flex-shrink-0 w-6 h-6 bg-emerald-500 rounded-full flex items-center justify-center text-white mt-1">
                                        <span className="text-sm">→</span>
                                    </div>
                                    <div>
                                        <h4 className="font-semibold text-lg mb-1">Trusted Platform</h4>
                                        <p className="text-slate-600">
                                            Join thousands of professionals who trust our platform for their
                                            career growth.
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <button
                                onClick={() => navigate("/register")}
                                className="mt-8 px-8 py-3 bg-slate-900 hover:bg-slate-800 text-white font-semibold rounded-xl transition shadow-lg"
                            >
                                Get Started
                            </button>
                        </div>
                    </div>
                </div>
            </section>

            {/* New Listed Jobs Section */}
            <section className="py-20 bg-slate-50">
                <div className="container mx-auto px-6">
                    <h2 className="text-3xl font-bold mb-10">New Listed Jobs</h2>
                    <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
                        {[1, 2, 3, 4].map((job) => (
                            <div key={job} className="bg-white rounded-xl p-6 shadow-md hover:shadow-xl transition">
                                <div className="flex items-center space-x-3 mb-4">
                                    <div className="w-12 h-12 bg-gradient-to-br from-emerald-400 to-cyan-500 rounded-lg flex items-center justify-center text-white font-bold">
                                        C
                                    </div>
                                    <div>
                                        <h3 className="font-semibold">Senior UX Designer</h3>
                                        <p className="text-sm text-slate-500">Company Name</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-2 text-sm text-slate-600 mb-3">
                                    <span className="px-3 py-1 bg-emerald-100 text-emerald-700 rounded-full">Full Time</span>
                                    <span>📍 Remote</span>
                                </div>
                                <p className="text-slate-600 text-sm mb-4">
                                    We are looking for an experienced UX designer to join our team...
                                </p>
                                <button className="w-full py-2 border-2 border-slate-900 text-slate-900 rounded-lg hover:bg-slate-900 hover:text-white transition font-medium">
                                    Apply Now
                                </button>
                            </div>
                        ))}
                    </div>
                    <div className="text-center mt-10">
                        <button
                            onClick={() => navigate("/jobs")}
                            className="px-8 py-3 bg-slate-900 hover:bg-slate-800 text-white font-semibold rounded-xl transition shadow-lg"
                        >
                            View All Jobs
                        </button>
                    </div>
                </div>
            </section>

            {/* Why People Love Us Section */}
            <section className="py-20">
                <div className="container mx-auto px-6">
                    <div className="grid md:grid-cols-2 gap-12 items-center">
                        <div>
                            <h2 className="text-4xl font-bold mb-6">
                                Why people love us as they got jobs of their choice
                            </h2>
                            <div className="space-y-4">
                                <div className="flex items-start space-x-3">
                                    <div className="flex-shrink-0 w-6 h-6 bg-emerald-500 rounded-full flex items-center justify-center text-white text-sm mt-1">
                                        ✓
                                    </div>
                                    <div>
                                        <h4 className="font-semibold mb-1">Get matched with the best</h4>
                                        <p className="text-slate-600 text-sm">
                                            Our AI-powered matching system connects you with jobs that fit your skills perfectly.
                                        </p>
                                    </div>
                                </div>
                                <div className="flex items-start space-x-3">
                                    <div className="flex-shrink-0 w-6 h-6 bg-emerald-500 rounded-full flex items-center justify-center text-white text-sm mt-1">
                                        ✓
                                    </div>
                                    <div>
                                        <h4 className="font-semibold mb-1">Get matched with your passion</h4>
                                        <p className="text-slate-600 text-sm">
                                            Find opportunities that align with your career goals and interests.
                                        </p>
                                    </div>
                                </div>
                                <div className="flex items-start space-x-3">
                                    <div className="flex-shrink-0 w-6 h-6 bg-emerald-500 rounded-full flex items-center justify-center text-white text-sm mt-1">
                                        ✓
                                    </div>
                                    <div>
                                        <h4 className="font-semibold mb-1">Personalized job recommendations</h4>
                                        <p className="text-slate-600 text-sm">
                                            Receive tailored job suggestions based on your profile and preferences.
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div className="relative">
                            <div className="bg-gradient-to-br from-slate-100 to-slate-200 rounded-3xl p-8">
                                <img
                                    src="https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=500&h=600&fit=crop"
                                    alt="Professional"
                                    className="rounded-2xl shadow-2xl w-full h-96 object-cover"
                                />
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* Top Ways to Help Section */}
            <section className="py-20 bg-gradient-to-br from-slate-700 via-slate-800 to-slate-900 text-white">
                <div className="container mx-auto px-6">
                    <h2 className="text-3xl font-bold text-center mb-12">Top ways to help you get ahead</h2>
                    <div className="grid md:grid-cols-3 gap-8">
                        <div className="text-center">
                            <div className="w-16 h-16 bg-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4">
                                <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
                                    <path d="M9 2a1 1 0 000 2h2a1 1 0 100-2H9z" />
                                    <path fillRule="evenodd" d="M4 5a2 2 0 012-2 3 3 0 003 3h2a3 3 0 003-3 2 2 0 012 2v11a2 2 0 01-2 2H6a2 2 0 01-2-2V5zm3 4a1 1 0 000 2h.01a1 1 0 100-2H7zm3 0a1 1 0 000 2h3a1 1 0 100-2h-3zm-3 4a1 1 0 100 2h.01a1 1 0 100-2H7zm3 0a1 1 0 100 2h3a1 1 0 100-2h-3z" clipRule="evenodd" />
                                </svg>
                            </div>
                            <h3 className="text-xl font-semibold mb-2">A Better Job</h3>
                            <p className="text-slate-300 text-sm mb-4">
                                Access thousands of verified job listings from top companies worldwide.
                            </p>
                            <button className="text-emerald-400 hover:text-emerald-300 text-sm font-medium">
                                Learn more →
                            </button>
                        </div>

                        <div className="text-center">
                            <div className="w-16 h-16 bg-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4">
                                <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
                                    <path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3zM6 8a2 2 0 11-4 0 2 2 0 014 0zM16 18v-3a5.972 5.972 0 00-.75-2.906A3.005 3.005 0 0119 15v3h-3zM4.75 12.094A5.973 5.973 0 004 15v3H1v-3a3 3 0 013.75-2.906z" />
                                </svg>
                            </div>
                            <h3 className="text-xl font-semibold mb-2">A Helpful Community</h3>
                            <p className="text-slate-300 text-sm mb-4">
                                Connect with professionals and get career advice from industry experts.
                            </p>
                            <button className="text-emerald-400 hover:text-emerald-300 text-sm font-medium">
                                Learn more →
                            </button>
                        </div>

                        <div className="text-center">
                            <div className="w-16 h-16 bg-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4">
                                <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
                                    <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
                                </svg>
                            </div>
                            <h3 className="text-xl font-semibold mb-2">A Standout Profile</h3>
                            <p className="text-slate-300 text-sm mb-4">
                                Create a professional profile that showcases your skills and experience.
                            </p>
                            <button className="text-emerald-400 hover:text-emerald-300 text-sm font-medium">
                                Learn more →
                            </button>
                        </div>
                    </div>
                    <div className="text-center mt-10">
                        <button className="px-8 py-3 bg-emerald-500 hover:bg-emerald-600 text-white font-semibold rounded-xl transition shadow-lg">
                            Get Started
                        </button>
                    </div>
                </div>
            </section>

            {/* Job Advisors Community Section */}
            <section className="py-20 bg-slate-50">
                <div className="container mx-auto px-6">
                    <h2 className="text-3xl font-bold text-center mb-4">
                        Join the biggest Community of Job Advisors
                    </h2>
                    <p className="text-center text-slate-600 mb-12">
                        Connect with industry experts and get personalized career guidance
                    </p>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-6 mb-10">
                        {[1, 2, 3, 4].map((advisor) => (
                            <div key={advisor} className="bg-white rounded-xl p-6 text-center shadow-md hover:shadow-xl transition">
                                <div className="w-20 h-20 bg-gradient-to-br from-slate-300 to-slate-400 rounded-full mx-auto mb-4"></div>
                                <h4 className="font-semibold mb-1">John Doe</h4>
                                <p className="text-sm text-slate-500 mb-2">Career Advisor</p>
                                <div className="flex items-center justify-center text-yellow-500 text-sm">
                                    ★★★★★
                                </div>
                            </div>
                        ))}
                    </div>
                    <div className="text-center">
                        <button className="px-8 py-3 bg-slate-900 hover:bg-slate-800 text-white font-semibold rounded-xl transition shadow-lg">
                            View All Advisors
                        </button>
                    </div>
                </div>
            </section>

            {/* Career Advice Section */}
            <section className="py-20">
                <div className="container mx-auto px-6">
                    <h2 className="text-3xl font-bold mb-10">Our Latest Career Advice</h2>
                    <div className="grid md:grid-cols-3 gap-8">
                        <div className="bg-white rounded-xl overflow-hidden shadow-md hover:shadow-xl transition">
                            <div className="h-48 bg-gradient-to-br from-blue-400 to-blue-600"></div>
                            <div className="p-6">
                                <h3 className="font-semibold text-lg mb-2">
                                    10 Great Tips to look for the job you want
                                </h3>
                                <p className="text-slate-600 text-sm mb-4">
                                    Discover proven strategies to find and land your dream job in today's competitive market.
                                </p>
                                <button className="text-slate-900 hover:text-emerald-600 font-medium text-sm">
                                    Read More →
                                </button>
                            </div>
                        </div>

                        <div className="bg-white rounded-xl overflow-hidden shadow-md hover:shadow-xl transition">
                            <div className="h-48 bg-gradient-to-br from-emerald-400 to-emerald-600"></div>
                            <div className="p-6">
                                <h3 className="font-semibold text-lg mb-2">
                                    How to build your dream career successfully
                                </h3>
                                <p className="text-slate-600 text-sm mb-4">
                                    Learn the essential steps to create a fulfilling and successful career path.
                                </p>
                                <button className="text-slate-900 hover:text-emerald-600 font-medium text-sm">
                                    Read More →
                                </button>
                            </div>
                        </div>

                        <div className="bg-white rounded-xl overflow-hidden shadow-md hover:shadow-xl transition">
                            <div className="h-48 bg-gradient-to-br from-purple-400 to-purple-600"></div>
                            <div className="p-6">
                                <h3 className="font-semibold text-lg mb-2">
                                    Essential interview tips for job seekers
                                </h3>
                                <p className="text-slate-600 text-sm mb-4">
                                    Master the art of interviewing with these expert tips and techniques.
                                </p>
                                <button className="text-slate-900 hover:text-emerald-600 font-medium text-sm">
                                    Read More →
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </section>


            {/* Footer */}
            <footer className="bg-slate-900 text-white py-12">
                <div className="container mx-auto px-6 text-center">
                    <div className="mb-6">
                        <div className="text-2xl font-bold">IT JOB HUNT</div>
                    </div>
                    <p className="text-slate-400">
                        © 2024 IT Job Hunt. All rights reserved.
                    </p>
                </div>
            </footer>
        </div>
    );
}
