import { useAuth } from '../hooks/useAuth';
import { Navigate } from 'react-router-dom';

export function ProtectedRoute({ children, allowedRoles = [] }) {
  const { user } = useAuth();
  console.log("ProtectedRoute user:", user);
//   if (!user) {
//     return <Navigate to="/login" replace />;
//   }

  if (allowedRoles.length > 0 && !allowedRoles.includes(user.roles?.[0]?.name)) {
    return <Navigate to="/unauthorized" replace />;
  }

  return children;
}

// trang ni la ai dang nhap moi vao dc va chia theo tung role