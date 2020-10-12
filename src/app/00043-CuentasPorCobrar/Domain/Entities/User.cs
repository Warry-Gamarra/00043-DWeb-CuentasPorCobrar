using Data.Tables;
using Data.Views;
using Domain.DTO;
using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Security;
using WebMatrix.WebData;

namespace Domain.Entities
{
    public class User : IUser
    {
        private readonly Webpages_Roles _roleRepository;
        private readonly VW_Usuario _userRepository;

        public int? UserId { get; set; }
        public string UserName { get; set; }
        public bool Enabled { get; set; }
        public Persona Person { get; set; }
        public Dependencia Dependencia { get; set; }
        public RolAplicacion Rol { get; set; }


        public User()
        {
            _userRepository = new VW_Usuario();
            _roleRepository = new Webpages_Roles();

            this.Person = new Persona();
            this.Dependencia = new Dependencia();
            this.Rol = new RolAplicacion();
        }

        public User(VW_Usuario usuario)
        {
            this.UserId = usuario.UserId;
            this.UserName = usuario.UserName;
            this.Enabled = usuario.B_Habilitado;
            this.Person = new Persona()
            {
                Id = usuario.I_DatosUsuarioID.HasValue ? usuario.I_DatosUsuarioID.Value : 0,
                NumDocIdentidad = usuario.N_NumDoc,
                correo = usuario.T_CorreoUsuario,
                Nombre = usuario.T_NomPersona
            };
            this.Dependencia = new Dependencia();
            this.Rol = new RolAplicacion()
            {
                Id = usuario.RoleId,
                NombreRol = usuario.RoleName
            };
        }



        public List<User> Find()
        {
            List<User> users = new List<User>();
            foreach (var item in _userRepository.Find())
            {
                users.Add(new User(item));
            }

            return users;
        }

        public User Get(int userId)
        {
            return new User(_userRepository.Find(userId));
        }

        public Response ChangeState(User userRegister, int currentUserId)
        {
            _userRepository.UserId = userRegister.UserId.Value;
            _userRepository.D_FecActualiza = DateTime.Now;
            _userRepository.B_Habilitado = !userRegister.Enabled;

            return new Response(_userRepository.ChangeState(currentUserId));

        }

        public Response Save(User user, int currentUserId, SaveOption saveOption)
        {
            if (user.UserId.HasValue)
            {
                _userRepository.UserId = user.UserId.Value;
            }

            _userRepository.UserName = user.UserName;
            _userRepository.I_UsuarioCrea = currentUserId;
            _userRepository.D_FecActualiza = DateTime.Now;
            _userRepository.B_Habilitado = true;

            _userRepository.I_DatosUsuarioID = user.Person.Id;
            _userRepository.T_NomPersona = user.Person.Nombre;
            _userRepository.N_NumDoc = user.Person.NumDocIdentidad;
            _userRepository.T_CorreoUsuario = user.Person.correo;
            _userRepository.D_FecAlta = DateTime.Now;
            _userRepository.RoleId = user.Rol.Id;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    return CreateAccount(_userRepository, user.Rol.Id);
                case SaveOption.Update:
                    return UpdateAccount(_userRepository);
            }
            return new Response() { Value = false, Message = "Operación inválida." };
        }


        private Response CreateAccount(VW_Usuario user, int roleId)
        {
            if (_userRepository.Find(user.UserName) != null)
            {
                return new Response()
                {
                    Value = false,
                    Message = "El nombre de usuario ya existe"
                };
            }

            string password = RandomPassword.Generate(8, RandomPassword.PASSWORD_CHARS_ALPHANUMERIC);
            WebSecurity.CreateUserAndAccount(
                user.UserName,
                password,
                new
                {
                    I_UsuarioCrea = user.I_UsuarioCrea,
                    B_CambiaPassword = false,
                    B_Habilitado = true
                });
            string roleName = _roleRepository.Find().SingleOrDefault(x => x.RoleId == roleId).RoleName;
            if (!Roles.IsUserInRole(user.UserName, roleName))
            {
                Roles.AddUserToRole(user.UserName, roleName);
            }

            _userRepository.UserId = _userRepository.Find(user.UserName).UserId;

            Response result = new Response(_userRepository.Insert());

            if (result.Value)
            {
                result.Message += ". Contraseña: " + password + ".";
                return result;
            }
            else
            {
                ((SimpleMembershipProvider)Membership.Provider).DeleteAccount(user.UserName);
                ((SimpleMembershipProvider)Membership.Provider).DeleteUser(user.UserName, true);

                result.Value = false;
                result.Message = "Ocurrio un error durante la creación de la cuenta";
            }
            return result; 
        }

        private Response UpdateAccount(VW_Usuario user)
        {
            return new Response(_userRepository.Update());
        }


        public Response GetUserState(string userName)
        {
            Response result = new Response();
            TC_Usuario usuario = _userRepository.Find(userName);

            if (usuario == null)
            {
                result.Value = false;
                result.Message = "No se encontró el usuario";
            }
            else
            {
                result.Value = usuario.B_Habilitado;
                if (!result.Value)
                {
                    result.Message = "La cuenta se encuentra deshabilitada temporalmente. Si el problema persiste comuníquese con el administrador del sistema.";
                }
            }

            return result;
        }
    }
}
