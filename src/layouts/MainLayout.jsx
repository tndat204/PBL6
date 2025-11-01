import Navbar from "../components/Navbar";
import Footer from "../components/Footer";
import banner from "../assets/bg.jpg";

const MainLayout = ({ children, showBanner = true }) => {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Navbar */}
      <Navbar />

      {/* Banner (optional) */}
      {showBanner && (
        <div
          className="relative bg-green-700 text-white py-40 text-center"
          style={{
            backgroundImage: `url(${banner})`,
            backgroundSize: "cover",
            backgroundPositionY: "-100px",
            backgroundPositionX: "center",
          }}
        >
          <div className="absolute inset-0 bg-black opacity-50"></div>
          <div className="relative z-10 max-w-7xl mx-auto px-6">
            <h1 className="text-4xl font-bold">
              Let's get you hired for the job you deserve!
            </h1>
            <p className="mt-2 text-lg">Find the job that suits you best</p>
          </div>
        </div>
      )}

      {/* Nội dung trang */}
      <main className="max-w-7xl mx-auto px-6 py-14">
        {children}
      </main>

      {/* Footer */}
      <Footer />
    </div>
  );
};

export default MainLayout;
