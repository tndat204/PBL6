import React from "react";

export default function RegisterRoleModal({ onSelectRole }) {
  return (
    <div className="fixed inset-0 bg-sea-100 bg-opacity-30 flex items-center justify-center z-50">
      <div className="bg-white rounded-2xl shadow-xl p-8 max-w-lg w-full text-center">
        <h2 className="text-2xl font-bold mb-2">Chào bạn,</h2>
        <p className="mb-6 text-gray-600">
          Bạn hãy dành ra vài giây để xác nhận thông tin dưới đây nhé!
        </p>
        <div className="flex justify-center gap-8">
          <div className="flex flex-col items-center">
            <img src="https://tuyendung.topcv.vn/app/_nuxt/img/bussiness.efbec2d.png" alt="Nhà tuyển dụng" className="w-32 h-32 object-cover rounded-full mb-3" />
            <button
              className="bg-sea-400 text-white px-6 py-2 rounded-full font-semibold hover:bg-sea-300"
              onClick={() => onSelectRole("employer")}
            >
              Tôi là nhà tuyển dụng
            </button>
          </div>
          <div className="flex flex-col items-center">
            <img src="https://tuyendung.topcv.vn/app/_nuxt/img/student.c1c39ee.png" alt="Ứng viên" className="w-32 h-32 object-cover rounded-full mb-3" />
            <button
              className="bg-sea-400 text-white px-6 py-2 rounded-full font-semibold hover:bg-sea-300"
              onClick={() => onSelectRole("candidate")}
            >
              Tôi là ứng viên tìm việc
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}