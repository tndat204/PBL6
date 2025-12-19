import { FaFacebookF, FaTwitter, FaInstagram } from 'react-icons/fa';

function Footer() {
  const currentDate = new Date().toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
  const currentTime = new Date().toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    timeZone: 'Asia/Bangkok',
    hour12: true,
  });

  return (
    <footer className="bg-slate-900 text-white py-12 mt-10">
      <div className="max-w-7xl mx-auto px-6 grid grid-cols-1 md:grid-cols-3 gap-8">
        {/* Company Info */}
        <div>
          <h3 className="text-lg font-semibold mb-4">IT Job Hunt</h3>
          <p className="text-slate-400 text-sm">
            Connecting talent with opportunities worldwide. Find your dream job with us!
          </p>
          <div className="flex space-x-4 mt-4">
            <a href="#" className="text-slate-400 hover:text-white">
              <FaFacebookF />
            </a>
            <a href="#" className="text-slate-400 hover:text-white">
              <FaTwitter />
            </a>
            <a href="#" className="text-slate-400 hover:text-white">
              <FaInstagram />
            </a>
          </div>
        </div>

        {/* Quick Links */}
        <div>
          <h3 className="text-lg font-semibold mb-4">Quick Links</h3>
          <ul className="space-y-2">
            <li><a href="#" className="text-slate-400 hover:text-white text-sm">Home</a></li>
            <li><a href="#" className="text-slate-400 hover:text-white text-sm">Jobs</a></li>
            <li><a href="#" className="text-slate-400 hover:text-white text-sm">Pages</a></li>
            <li><a href="#" className="text-slate-400 hover:text-white text-sm">Contact</a></li>
          </ul>
        </div>

        {/* Contact Info */}
        <div>
          <h3 className="text-lg font-semibold mb-4">Contact Us</h3>
          <p className="text-slate-400 text-sm">Email: support@itjobhunt.com</p>
          <p className="text-slate-400 text-sm">Phone: +1-800-123-4567</p>
          <p className="text-slate-400 text-sm">Address: 123 Job Street, Tech City</p>
          <p className="text-slate-400 text-sm mt-2">
            © {currentDate} {currentTime} +07
          </p>
        </div>
      </div>
    </footer>
  );
}

export default Footer;
