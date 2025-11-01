import FormLayout from "../layouts/FormLayout";

function ApplyJob() {
  return (
    <FormLayout>
      <h1 className="text-2xl font-bold mb-6 text-center text-gray-700">Apply for this Job</h1>
      <form className="space-y-4">
        {/* Categories */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">Categories:</label>
          <input
            type="text"
            placeholder="Web Designer"
            className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
          />
        </div>

        {/* Name */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">Your name:</label>
          <input
            type="text"
            placeholder="A Nguyen Van"
            className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
          />
        </div>

        {/* Email */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">Email:</label>
          <input
            type="email"
            placeholder="nguyenvana@gmail.com"
            className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
          />
        </div>

        {/* Phone */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">Phone No.:</label>
          <input
            type="tel"
            placeholder="Phone number"
            className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
          />
        </div>

        {/* Note */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">Note:</label>
          <textarea
            placeholder="Note..."
            rows={3}
            className="w-full border border-gray-300 rounded px-3 py-2 text-gray-600 focus:outline-none focus:ring-1 focus:ring-sea-200"
          ></textarea>
        </div>

        {/* Upload Resume */}
        <div>
          <label className="block text-md font-medium mb-1 text-gray-700">Upload Resume:</label>
          <input
            type="file"
            className="w-full border border-gray-300 rounded  py-2 file:mr-4 file:py-2 file:px-4 file:rounded file:border-0  file:text-gray-600 cursor-pointer"
          />
        </div>

        {/* Button */}
        <div>
          <button
            type="submit"
            className="bg-sea-400 text-white px-6 py-2 rounded hover:bg-sea-300 transition-colors w-full md:w-auto"
          >
            Apply
          </button>
        </div>
      </form>
    </FormLayout>
  );
}

export default ApplyJob;
