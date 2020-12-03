using Domain.DTO;
using Domain.Entities;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Data;
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

            foreach (var item in _userManual.Find().Where(x => x.Rol == roleId && x.RolHabilitado))
            { 
                result.Add(new UserManualViewModel(item));
            }

            return result;
        }

        public List<UserManualViewModel> ObtenerManuales()
        {
            List<UserManualViewModel> result = new List<UserManualViewModel>();

            var data = _userManual.Find();

            foreach (var item in data.Select(x => new { x.Id, x.Documento, x.Url, x.Habilitado }).Distinct())
            {
                var userManual = new UserManualViewModel()
                {
                    RutaID = item.Id,
                    FileName = item.Documento,
                    FilePath = item.Url,
                    Habilitado = item.Habilitado
                };

                for (int i = 0; i < userManual.Roles.Count(); i++)
                {
                    foreach (var docItem in data.Where(x => x.Id == item.Id))
                    {
                        if (docItem.Rol == userManual.Roles[i].RoleId)
                        {
                            userManual.Roles[i].Habilitado = docItem.RolHabilitado;
                        }
                    }
                }
                result.Add(userManual);
            }

            return result;
        }

        public UserManualViewModel ObtenerManualUsuario(int manualUsuarioId)
        {
            var data = _userManual.Find(manualUsuarioId);
            if (data.Count > 0)
            {
                var result = new UserManualViewModel(data.First());

                for (int i = 0; i < result.Roles.Count(); i++)
                {
                    foreach (var item in data)
                    {
                        if (item.Rol == result.Roles[i].RoleId)
                        {
                            result.Roles[i].Habilitado = item.RolHabilitado;
                        }

                    }
                }
                return result;
            }

            return new UserManualViewModel();
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

            DataTable dtRoles = new DataTable();

            dtRoles.Columns.Add("RoleID");
            dtRoles.Columns.Add("RoleName");
            dtRoles.Columns.Add("CheckValue");

            foreach (var role in model.Roles)
            {
                dtRoles.Rows.Add(role.RoleId, role.RoleName, role.Habilitado);
            }

            Response result = _userManual.Save(manualUsuario, dtRoles, currentUserId, (model.RutaID == 0 ? SaveOption.Insert : SaveOption.Update));

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