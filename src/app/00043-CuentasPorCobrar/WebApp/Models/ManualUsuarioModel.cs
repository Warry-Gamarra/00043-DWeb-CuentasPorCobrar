using Domain.DTO;
using Domain.Entities;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class ManualUsuarioModel
    {
        private readonly IHelpResources _userManual;
        private readonly IRoles _roles;

        public ManualUsuarioModel()
        {
            _userManual = new HelperResources();
            _roles = new RolAplicacion();
        }

        public List<UserManualViewModel> ObtenerManualesPorUsuario(int currentUserId)
        {
            int? roleId = _roles.FindByUser(currentUserId).Id;
            List<UserManualViewModel> result = new List<UserManualViewModel>();

            foreach (var item in _userManual.Find().Where(x => x.Rol == roleId))
            {
                result.Add(new UserManualViewModel(item));
            }

            return result;
        }

        public List<UserManualViewModel> ObtenerManuales()
        {
            List<UserManualViewModel> result = new List<UserManualViewModel>();

            foreach (var item in _userManual.Find())
            {
                result.Add(new UserManualViewModel(item));
            }

            return result;
        }

        public UserManualViewModel ObtenerManualUsuario(int manualUsuarioId)
        {
            UserManualViewModel result = new UserManualViewModel(_userManual.Find(manualUsuarioId));

            foreach (var rol in _roles.Find())
            {
                foreach (var item in result.Roles)
                {
                    if (item.RoleId == rol.Id)
                    {
                        result.Roles.Add(new RolesAsociadosViewModel(rol, true));
                    }
                    else
                    {
                        result.Roles.Add(new RolesAsociadosViewModel(rol, false));
                    }
                }
            }

            return result;
        }

        public Response Save(UserManualViewModel model, int currentUserId)
        {
            HelperResources manualUsuario = new HelperResources()
            {
                Id = model.RutaID,
                Documento = model.FileName,
                Url = model.FilePath,
                Habilitado = model.Habilitado,
            };

            Response result = _userManual.Save(manualUsuario, currentUserId, (model.RutaID == 0 ? SaveOption.Insert : SaveOption.Update));

            if (result.Value)
            {
                result.Success(false);
            }
            else
            {
                result.Error(true);
            }
            return result;
        }

        internal object ChangeState(int rowID, bool b_habilitado, int currentUserId, string v)
        {
            throw new NotImplementedException();
        }
    }
}